# encoding: utf-8

def resolve_symbol(symbol)
  solr_url = $solr_prefix + "undr.identifier.symbol%3A%22#{symbol}%22" + $solr_suffix
  solr_response = JSON.parse(open(solr_url).read)
  if solr_response["response"]["numFound"] > 0
    # There is at least one match. Let's find out if the first document in the set has the same symbol as our search term.
    if solr_response["response"]["docs"].first["undr.identifier.symbol"].first == symbol
      handle = solr_response["response"]["docs"].first["handle"]
      return $repository_url + "/handle/" + handle
    else
      # It's close but not an exact match. Kick the user back to DSpace discovery.
      return $discovery_prefix + symbol + $discovery_suffix
    end
  else
    # return a redirect to DSpace discovery with the symbol as a search term
    return $discovery_prefix + symbol + $discovery_suffix
  end
  return false
end

def generate_oembed(url,params)
  handle = url.split(/\/handle\//).last
  #solr_url = $solr_prefix + "handle%3A#{handle}" + $solr_suffix
  #solr_response = JSON.parse(open(solr_url).read)
  #if solr_response["response"]["numFound"] == 1
  maxwidth = 300
  maxheight = 400
  container = "iframe"
  if params["maxwidth"]
    maxwidth = params["maxwidth"]
  end
  if params["maxheight"]
    maxheight = params["maxheight"]
  end
  if params["container"]
    container = params["container"]
  end
  generated_html = "<iframe src=\"#{$repository_url}/services/embed/handle/#{handle}\" width=\"#{maxwidth}\" height=\"#{maxheight}\"></iframe>"
  response = {
    "url" => "#{url}",
    "type" => "rich",
    "provider_name" => "#{$repository_desc}",
    "provider_url" => "#{$repository_url}",
    "html" => "#{generated_html}",
    "width" => maxwidth,
    "height" => maxheight
  }.to_json
  # To do: build a list of useful and available metadata fields for inclusion in the embed
  # Optional: Farm out full metadata selection to a standalone advanced builder page; include styling?
  return response
end

def unstyle(url,params)
  #params["metadata"] must be a list of fully qualified metadata fields to include
  #The question here is what risk there is in allowing arbitrary text. I think the risk of an exploit here is low, because I'm only going to 
  # test against what I'm already pulling from Solr. None of these metadata fields get passed beyond this application. Still, it's worth 
  # considering whether any improvements to security are necessary here.
  handle = url.split(/\/handle\//).last.split("?").first
  solr_url = $solr_prefix + "handle%3A#{handle}" + $solr_suffix
  solr_response = JSON.parse(open(solr_url).read)
  style = ""
  html = ""
  metadata = params["metadata"].split(",")
  if solr_response["response"]["numFound"] == 1
    doc = solr_response["response"]["docs"].first
    metadata.each do |m|
      if doc[m]
        html += "<p id=\"#{m}\">#{doc[m].first}</p>"
      end
    end
    return html
  else
    return nil
  end
end

def whitelist_params(allowed,passed)
  params = Hash.new
  passed.keys.each do |k|
    if allowed.include?(k)
      params[k] = passed[k]
    end
  end
  return params
end