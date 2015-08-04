# encoding: utf-8

def unstyle_response(object,disposition)
  default_metadata = ["undr.identifier.symbol","dc.title","dc.date.issued","dc.identifier.uri"]
  response = ''
  if disposition == 'item'
    #use solr and get yummy JSON
    handle = object
    solr_url = $solr_prefix + "handle%3A#{handle}" + $solr_suffix
    solr_response = JSON.parse(open(solr_url).read)
    style = ""
    html = ""
    if solr_response["response"]["numFound"] == 1
      doc = solr_response["response"]["docs"].first
      # make a URI
      uri = doc['dc.identifier.uri'].first
      if doc['undr.identifier.symbol'].size > 0
        uri = $repository_url + "/services/symbol/" + doc['undr.identifier.symbol'].first
      end
      
      default_metadata.each do |m|
        if doc[m]
          if m =~ /title/
            html += "<h3 id=\"#{m}\"><a href=\"#{uri}\">#{doc[m].first}</a></h3>"
          else
            html += "<p id=\"#{m}\">#{doc[m].first}</p>"
          end
        end
      end
      return html
    else
      return nil
    end

  elsif disposition == 'list'
    #have to parse XML, I'm afraid. Blech.
    url = ''
    if object =~ /11176/
      if object =~ /\?/
        url = $repository_url + "/handle/" + object + "&XML"
      else
        url = $repository_url + "/handle/" + object + "?XML"
      end
    else
      if object =~ /\?/
        url = $repository_url + '/' + object + "&XML"
      else
        url = $repository_url + '/' + object + "?XML"
      end
    end
    
    xml = Nokogiri::XML(open(url))
    list = xml.at("list[@n='item-result-list']").children
    results = []

    list.each do |item|
      i = []
      item.children.each do |metadata|
        child_metadata = []
        default_metadata.each do |m|
          if metadata["n"] =~ /#{m}/
            v = metadata.content
            child_metadata << {:key => m, :value => v}
          end
        end
        if child_metadata.size > 0 
          i << child_metadata
        end
      end
      results << i
    end
    
    title = ''
    uri = ''
    symbol = ''
    issued = ''
    
    results.uniq.each do |i|
      i.each do |c|
        c.each do |m|
          case m[:key]
          when /title/
            title = m[:value]
          when /symbol/
            symbol = m[:value]
          when /issued/
            issued = m[:value]
          when /uri/
            uri = m[:value]
          end
        end
      end
      if title.size > 0 && issued.size > 0
        title = title.split(/\n/)[1]
        response << "<p><a href=\"#{uri}\" target=\"_blank\">#{[symbol,title].join(' - ')}</a>: <span>(#{issued})</span></p>"
      end
    end
    return "<p><h3>Search results:</h3>#{response}</p><p>See more: <a href=\"#{url.gsub(/\&XML/,'').gsub(/\?XML/,'')}\" target=\"_blank\">#{url.gsub(/\&XML/,'').gsub(/\?XML/,'')}</a></p>"
  end
end

def generate_response(params)
  #The incoming url should be encoded/escaped
  decoded = URI::decode(params["url"])
  object = ''
  if params["type"] == 'item'
    object = URI::encode(decoded.split(/\/handle\//).last.split(/\?/).first,/\W/)
  elsif params["type"] == 'list'
    if decoded =~ /handle/
      object = URI::encode(decoded.split(/\/handle\//).last,/\W/)
    else
      object = URI::encode(decoded.split(/\?/).last,/\W/)
    end
  end
  return {
    :url => params["url"],
    :type => "rich",
    :provider => $repository_desc,
    :provider_url => $repository_url,
    :width => params["maxwidth"],
    :height => params["maxheight"],
    :html => "<iframe src=\"#{$repository_url}/services/embed?object=#{object}&type=#{params["type"]}\" height=\"#{params["maxheight"]}\" width=\"#{params["maxwidth"]}\"></iframe>"
  }.to_json
end