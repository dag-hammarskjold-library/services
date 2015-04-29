# encoding: utf-8

# To do: Set 501 response for not implemented; 404 for not found; etc. Make some other parameters available.

class Embed
  def self.call(env)
    req = Rack::Request.new(env)
    #if req.params["format"]
    #  Rack::Response.new(
    #    "<h1>501 Not Implemented</h1><p>Responses are formatted as JSON only. There is no need to specify a format, as no other formats are implemented.</p>",
    #    501,{'Content-Type' => 'text/html'}
    #  )
    #end
    case req.path
    when /^\/dsoembed$/
      if req.params["url"]
        #url is the only required parameter; others are optional; json is the only supported format!
        url = ''
        if req.params["url"] =~ /(.*)\.un\.org\/handle\/(.*)/
          url = req.params["url"]
          maxwidth = 300
          maxheight = 400
          if req.params["maxwidth"]
            if req.params["maxwidth"].to_i > 0
              maxwidth = req.params["maxwidth"].to_i
            end
          end
          if req.params["maxheight"]
            if req.params["maxheight"].to_i > 0
              maxheight = req.params["maxheight"].to_i
            end
          end
          format = { :name => 'json', :mimetype => 'application/json' }
          handle = url.split(/\/handle\//).last
          embed_src_url = "http://dag.un.org/dsoembed/embed/handle/#{handle}"
          generated_html = '<iframe src="' + embed_src_url + '" frameborder="0" style="top: 0px;left: 0px; width: ' + maxwidth.to_s + '; height: ' + maxheight.to_s + '; position: absolute;"></iframe>'
        
          response = {
            "url" => "#{url}",
            "type" => "rich",
            "provider_name" => "United Nations Dag Hammarskjöld Library",
            "provider_url" => "http://dag.un.org",
            "html" => "#{generated_html}",
            "width" => "#{maxwidth}",
            "height" => "#{maxheight}"
          }.to_json
      
          Rack::Response.new(response,200,{'Content-Type' => format[:mimetype]})
      
        else
          Rack::Response.new("<h1>401 Not Authorized</h1><p>The URL you specified is not within the URL scheme supported by this service.</p>",401,{'Content-Type' => 'text/html'})
        end
      else
        Rack::Response.new("<h1>400 Bad Request</h1><p>Required parameter 'url' is missing.</p>",400,{'Content-Type' => 'text/html'})
      end
    when /^\/dsoembed\/embed\/(.*)/
      handle = req.path.split(/\/handle\//).last
      solr_url_for_handle = $solr_prefix + handle + $solr_suffix
      handle_response_json = JSON.parse(open(solr_url_for_handle).read)
      generated_html = ''
      
      if handle_response_json["response"]["numFound"] && handle_response_json["response"]["numFound"].to_i > 0
        #start with an item, search.resourcetype 2
        if handle_response_json["response"]["docs"].first["search.resourcetype"].to_i == 2
          doc = handle_response_json["response"]["docs"].first
          generated_html += "<h2>#{doc['dc.title'].first}</h2><p>#{doc['author'].first}</p><p><a href=\"#{doc['dc.identifier.uri'].first}\">#{doc['dc.identifier.uri'].first}</a></p><p>#{doc['dc.description.abstract'].first}</p>"
        end
      end
      
      Rack::Response.new(generated_html,200,{'Content-Type' => 'text/html'})
    else
      Rack::Response.new("something is not right here...\n\n #{req.path}",404)
    end
  end
end