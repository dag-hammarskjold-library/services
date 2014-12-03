require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

get '/' do
  'Hello world'
end

get '/test' do
  html = "<ul>\n"
  url = URI.parse("http://54.172.204.197/rest/collections/7?expand=items")
  req = Net::HTTP::Get.new(url.request_uri)
  req['Accept'] = "application/json"
  res = Net::HTTP.new(url.host,url.port).start do |http|
    http.request(req)
  end 
  json = JSON.parse(res.body.to_s)
  json["items"].each do |item|
    link_html = ''
    html += "<li>\n"
    dc_keys = ['dc.title','dc.date.issued','dc.contributor.author','dc.creator','undr.contributor.corporate','undr.contributor.personal']
    item_url = URI.parse("http://54.172.204.197/rest/items/#{item["id"].to_s}?expand=metadata")
    item_url.to_s
    item_req = Net::HTTP::Get.new(item_url.request_uri)
    item_req['Accept'] = "application/json"
    item_res = Net::HTTP.new(item_url.host,item_url.port).start do |http|
      http.request(item_req)
    end
    item = JSON.parse(item_res.body.to_s)
    item["metadata"].each do |metadata|
      if dc_keys.include?(metadata["key"])
        html += "<span id=\"#{metadata["key"]}\">#{metadata["value"].to_s}</span>"
      end
      if metadata["key"] == 'dc.identifier.uri'
        link_html = "<span id=\"#{metadata["key"]}\"><a href=\"#{metadata["value"]}\" target=\"_blank\">#{metadata["value"]}</a></span>"
      end
    end
    html += link_html 
    html += "</li>\n"
  end
  html += "</ul>\n"
  html
end

get '/embed?:url?' do
  # Other parameters we might want include the set of metadata we want to show.  Maybe in a later version.
  url = params[:url]
  if url =~ /un.org/ || url =~ /54.172.204.197/
    if url =~ /rest/
      # if it has /rest/ in the path, we know it's a community, collection, item, etc., and we can go ahead and process it
      if url =~ /community/

      elsif url =~ /collection/

      elsif url =~ /item/

      end
    elsif url =~ /handle/
      # if it has /handle/ in the path, we have to look up the rest id

    else
      # otherwise it's a set of search results, which takes a whole different path

    end
  end
end
