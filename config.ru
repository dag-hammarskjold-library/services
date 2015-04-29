require 'rack'
require 'open-uri'
require 'json'

require 'embed'

#global things. Later, the number of rows should be made configurable

$solr_prefix = "http://localhost:8080/solr/search/select/?q=handle%3A"
$solr_suffix = "&start=0&rows=10&wt=json&indent=true"

run Embed