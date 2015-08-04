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