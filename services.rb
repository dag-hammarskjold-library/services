class Services
  def self.call(env)
    response = ''
    response_code = 200
    content_type = 'text/html; charset=utf-8'
    
    req = Rack::Request.new(env)
    
    if req.base_url != $repository_url
      $repository_url = req.base_url
    end
    
    res = nil
    
    case req.path
    when /^\/services$/,/^\/services\/$/
      # service definition page; should provide basic documentation
      response = "<p>...</p>"
    when /^\/services\/symbol\/(.*)/
      # /services/symbol/* - Try to resolve the symbol to a URL and redirect to it
      symbol = URI::encode(req.path.split(/\/symbol\//).last)
      url = resolve_symbol(symbol)
      if url
        #If this works, we just redirect and don't worry about the response code, etc.
        res = Rack::Response.new
        res.redirect(url, status=302)
        res.finish
        #response = "<p>found #{url}</p>"
      else
        response = $error_404 + $go_home
        response_code = 404
        Rack::Response.new(response,response_code,{'Content-Type' => content_type})
      end
    when /^\/services\/resolve\/(.*)/
      # /services/resolve/* - Try to resolve the symbol to a URL and display it as a JSON result
      symbol = URI::encode(req.path.split(/\/resolve\//).last)
      url = resolve_symbol(symbol)
      if url && url =~ /handle\/11176\/(\d+)/
        response = {
          :url => url
        }.to_json
        content_type = 'application/json; charset=utf-8'
      else
        response = $error_404 + $go_home
        response_code = 404
      end
      Rack::Response.new(response,response_code,{'Content-Type' => content_type})
    when /^\/services\/oembed$/,/^\/services\/oembed\/$/
      #get the encoded url and the type from the params
      if req.params["url"] && req.params["type"]
        response = generate_response(req.params)
        content_type = 'application/json; charset=utf-8'
      else
        additional_info = "<p>'url' and 'type' are required parameters</p>"
        response = $error_400 + additional_info + $go_home
        response_code = 400
      end
      Rack::Response.new(response,response_code,{'Content-Type' => content_type})
    when /^\/services\/embed$/,/^\/services\/embed\/$/    
      # possible params: object/query string, metadata (csv), object type; object and type are required
      if req.params["object"] && req.params["type"]
        #response = "<p>got #{req.url}</p>"
        if req.params["object"] =~ /11176/ || req.params["object"] =~ /discover/ || req.params["object"] =~ /scope/
          response = unstyle_response(req.params["object"],req.params["type"])
        else
          # Nothing to see
          additional_info = "<p>The embed target you specified is invalid.</p>"
          response = $error_403 + additional_info + $go_home
          response_code = 403
        end
      else
        additional_info = "<p>'object' and 'type' are required parameters</p>"
        response = $error_400 + additional_info + $go_home
        response_code = 400
      end
      Rack::Response.new(response,response_code,{'Content-Type' => content_type})
    else
      # whatever is being requested is beyond the scope of this application
      response = $error_404 + $go_home
      response_code = 404
      Rack::Response.new(response,response_code,{'Content-Type' => content_type})
    end
  end
end
