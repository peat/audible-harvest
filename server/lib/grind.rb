class MHDApp

  get '/grind.html' do
    erb :'grind'
  end

  post '/grind' do
    content_type :json

    url = URI.parse( params['url'] )

    found = false 
    until found 
      host, port = url.host, url.port if url.host && url.port 
      req = Net::HTTP::Get.new(url.path) 
      res = Net::HTTP.start(host, port) {|http|  http.request(req) } 
      res.header['location'] ? url = URI.parse(res.header['location']) : 
    found = true 
    end 

    res.body
  end

end
