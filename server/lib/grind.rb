class MHDApp

  SOUNDCLOUD_CLIENT_ID = 'aba5e923e867c06bdda5e282e933341d'

  get '/grind.html' do
    erb :'grind'
  end

  post '/grind' do
    content_type :json

    url = URI.parse( params['url'] )
    person = params['person']
    origin = params['origin']

    # follow through all redirects!
    url = follow_redirects( url )

    out = {}

    # figure out where the URL points. 
    case url.host
      when /soundcloud\.com/
        data = soundcloud_data( url.to_s )
        out = {
          :person => person,
          :track => data['title'],
          :artist => data['user']['username'],
          :provider => 'Soundcloud',
          :origin => origin
        }
        Treasure.create( out )
      else
        out = { :unknown => url.to_s }
    end

    out.to_json
  end

  def follow_redirects( url )
    found = false 
    until found 
      puts "Following #{url.to_s}"
      host, port = url.host, url.port if url.host && url.port 
      req = Net::HTTP::Get.new(url.path) 
      res = Net::HTTP.start(host, port) {|http|  http.request(req) } 
      res.header['location'] ? url = URI.parse(res.header['location']) : found = true 
    end 

    url
  end

  # web_url is a string like: http://soundcloud.com/skrillex/nero-promises-skrillex
  # returns a JSON object
  def soundcloud_data( web_url )
    raw_follow = "http://api.soundcloud.com/resolve.json?client_id=#{SOUNDCLOUD_CLIENT_ID}&url=#{URI.escape(web_url)}"
    follow = URI.parse( raw_follow )
    JSON.parse( open( follow.to_s ).read )
  end

end
