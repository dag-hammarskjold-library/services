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
  if params["maxwidth"]
    maxwidth = params["maxwidth"]
  end
  if params["maxheight"]
    maxheight = params["maxheight"]
  end
  generated_html = ""
  response = {
    "url" => "#{url}",
    "type" => "rich",
    "provider_name" => "United Nations Dag Hammarskjöld Library",
    "provider_url" => "http://dag.un.org",
    "html" => "#{generated_html}",
    "width" => "#{maxwidth}",
    "height" => "#{maxheight}"
  }.to_json
  return response
end

def unstyle(url)
  html = ''
  return html
end