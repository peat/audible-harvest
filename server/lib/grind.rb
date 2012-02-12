class MHDApp

  SOUNDCLOUD_CLIENT_ID = 'aba5e923e867c06bdda5e282e933341d'
  TUMBLR_API_KEY = 'sK6Kj5Ts49pAosgwiFDG8oYAgQpgsQFZ56PZy93pSlFZnpBl7o'

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
        # last resort: check to see if it's a tumblr blog
        tumblr_set = tumblr_data( url.to_s )
        if (tumblr_set.length > 0)
          # woot woot
          tumblr_set.each do |t|
            p = t['response']['posts'].first
            out = {
              :person => person,
              :track => p['track_name'],
              :artist => p['artist'],
              :provider => 'Tumblr',
              :origin => origin
            }
            Treasure.create( out )
          end
        end
    end

    out.to_json
  end

  def follow_redirects( url )

    begin
      found = false 
      until found 
        puts "Following #{url.to_s}"
        original_url = url
        host, port = url.host, url.port if url.host && url.port 
        req = Net::HTTP::Get.new(url.path) 
        res = Net::HTTP.start(host, port) {|http|  http.request(req) } 
        if res.header['location']
          unless res.header['location'] =~ /^http/ # ensure it's an absolute url
            url = URI.parse("http://#{url.host}:#{url.port}/#{res.header['location']}")
          else
            url = URI.parse(res.header['location']) 
          end
        else
          return url
        end

        return url if (original_url == url) # prevent hot loop
      end 
    rescue => e
      puts e
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

  def tumblr_data( web_url )
    results = []

    begin
      doc = Nokogiri::HTML(open(web_url))
      uri = URI.parse(web_url)

      tumblr_api_url = "http://api.tumblr.com/v2/blog/#{uri.host}/posts?api_key=#{TUMBLR_API_KEY}&id="

      # find class="post audio"
      doc.css("div.audio").each do |audio_div|
        # get the id, from the string "post-idstring"
        raw_id = audio_div.attribute("id").value()
        id = raw_id.split('-').last
        request_url = tumblr_api_url + id
        results << JSON.parse( open(request_url).read )
      end
    rescue => e
      puts e
    end

    results
  end

end
