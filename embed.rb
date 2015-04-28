class Embed
  def self.call(env)
    req = Rack::Request.new(env)
    case req.path
    # The embed request can be for several different things: a community/collection scope, an item, or a set of existing search results. We need to find out which.
    when /^\/handle\/\d+\/\d+$/
      #handle to resolve, get some data and serialize it as JSON for the client to parse
      param = req.path.split(/\/handle\//).last
      handle = URI::encode(param)
      solr_for_handle = "http://localhost:8080/solr/search/select?q=handle%3A#{handle}&start=0&rows=1&wt=json&indent=true"
      #What am I?
      # Item = resourcetype: 2
      # Collection = resourcetype: 3
      # Community = resourcetype: 4
      search_response = open(solr_for_handle).read
      if search_response
        json = JSON.parse(search_response)
        #Rack::Response.new(json["response"]["docs"].first["search.resourcetype"].to_s)
        #else
        resource_type = json["response"]["docs"].first["search.resourcetype"].to_s
        solr_for_resource = "http://localhost:8080/solr/search/select?q="
        generated_html = "<h3>#{json["response"]["docs"].first["dc.title"].first}</h3>"
        case resource_type
        when "2"
          #item, we already have all of the data we need
          Rack::Response.new(generated_html,200,{'Content-Type' => 'text/html'})
        when "3"
          #collection, let's find the first 10 rows belonging to location.coll:n
          coll_search = "http://localhost:8080/solr/search/select?q=location.coll%3A#{json["response"]["docs"].first["search.resourceid"].to_s}&start=0&rows=10&wt=json&indent=true" 
          coll_results = open(coll_search).read
          coll_json = JSON.parse(coll_results)
          coll_json["response"]["docs"].each do |doc|
            generated_html += "<p>#{doc["dc.title"].first}</p>"
          end
          Rack::Response.new(generated_html,200,{'Content-Type' => 'text/html'})
        when "4"
          #community, let's find the first 10 rows belonging to location.comm:n
          comm_search = "http://localhost:8080/solr/search/select?q=location.comm%3A#{json["response"]["docs"].first["search.resourceid"].to_s}&start=0&rows=10&wt=json&indent=true" 
          comm_results = open(comm_search).read
          comm_json = JSON.parse(comm_results)
          comm_json["response"]["docs"].each do |doc|
            generated_html += "<p>#{doc["dc.title"].first}</p>"
          end
          Rack::Response.new(generated_html,200,{'Content-Type' => 'text/html'})
        end
      end
    else
      #nothing here, toss a 404
      Rack::Response.new("Not found", 404)
    end
  end
end