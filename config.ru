# encoding: utf-8

require 'rack'
require 'open-uri'
require 'json'

require 'services'
require 'functions'

# Configure these to match your DSpace environment
$solr_prefix = "http://localhost:8080/solr/search/select?q="
$solr_suffix = "&start=0&rows=10&wt=json&indent=true"

$repository_url = "http://dag.un.org"
$repository_desc = "United Nations Dag Hammarskjöld Library"
$discovery_prefix = $repository_url + "/discover?scope=%2F&query="
$discovery_suffix = "&submit"

# More global declarations, mostly error messages
$error_400 = "<h1>400 - Bad Request</h1><p>The server wasn't able to figure out what you were requesting. Check your parameters and try again.</p>"
$error_403 = "<h1>403 - Forbidden</h1><p>You are not authorized to access the requested resource in the manner you have specified.</p>"
$error_404 = "<h1>404 - Not Found</h1><p>The resource you are requesting cannot be found.</p>"
$error_501 = "<h1>501 - Not Implemented</h1><p>The resource, function, or format you are requesting has not been implemented. Check your request and try again.</p>"

$go_home = "<p>Go <a href=\"/services/\">home</a>.</p>"

run Services