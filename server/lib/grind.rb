class MHDApp

  SOUNDCLOUD_CLIENT_ID = 'aba5e923e867c06bdda5e282e933341d'
  TUMBLR_API_KEY = 'sK6Kj5Ts49pAosgwiFDG8oYAgQpgsQFZ56PZy93pSlFZnpBl7o'

  get '/grind.html' do
    erb :'grind'
  end

  post '/grind' do
    content_type :json

    out = { :error => "Timeout exceeded processing #{url}" }

    # 5 second limit!
    begin
      Timeout::timeout(5) {
        url = URI.parse( params['url'] )
        person = params['person']
        origin = params['origin']

        # follow through all redirects!
        url = follow_redirects( url )

        out = treasure_for( url )

        out = out.collect do |t|
          # add in person, origin, and save it
          t[:person] = person
          t[:origin] = origin
          Treasure.create(t)

          t
        end
      }
    rescue => e
      puts e
    end

    out.to_json
  end


  def treasure_for( url )
    out = []

    # first shot: work on direct URLs.
    case url.host
      when /soundcloud\.com/
        out = grind_soundcloud( url )
      when /open\.spotify\.com/
        out = grind_spotify( url )
      when /tumblr\.com/
        out = grind_tumblr( url )
    end

    # drop out if we have data
    return out unless out.empty?

    # second shot: grind on content
    content = Nokogiri::HTML(open(url.to_s))
    grind_content( url )
  end


  def grind_soundcloud( url )
    begin
      raw_follow = "http://api.soundcloud.com/resolve.json?client_id=#{SOUNDCLOUD_CLIENT_ID}&url=#{URI.escape(url.to_s)}"
      follow = URI.parse( raw_follow )
      data = JSON.parse( open( follow.to_s ).read )
      treasure = {
        :track => data['title'],
        :artist => data['user']['username'],
        :provider => 'Soundcloud',
      }

      [treasure]
    rescue =>e
      puts e
    end

    []
  end

  def grind_spotify( url )
    # change 'http://open.spotify.com/album/43uj7422MLR9MRBXSki0El' into 'spotify:album:43uj7422MLR9MRBXSki0El'
    path_fragments = url.path.split('/').join(":")
    spotify_uri = "spotify#{path_fragments}"

    # use spotify lookup for rich XML info; be sure to include track info
    lookup_url = "http://ws.spotify.com/lookup/1/?uri=#{spotify_uri}&extras=track"
    doc = Nokogiri::XML(open(lookup_url))

    # use only the first track and artist it finds
    track = doc.css('track>name').first.text.strip
    artist = doc.css('track>artist').first.text.strip

    treasure = {
      :track => track,
      :artist => artist,
      :provider => 'Spotify'
    }

    [treasure]
  end

  def grind_tumblr( url )
    begin
      api_url = "http://api.tumblr.com/v2/blog/#{url.host}/posts/audio?api_key=#{TUMBLR_API_KEY}"
      data = JSON.parse(open(api_url).read)
      most_recent = data['response']['posts'].last

      treasure = {
        :track => most_recent['track_name'],
        :artist => most_recent['artist'],
        :provider => 'Tumblr'
      }
      return [treasure]
    rescue => e
      puts e
    end

    return []
  end


  def grind_content( url )
    doc = Nokogiri::HTML(open(url.to_s))
    out = []

    # gather up the links ...
    links = []
    doc.css('a').each do |a|
      links << a.attribute('href')
    end

    # find the first viable link to a service we recognize
    links.each do |link|
      case url.host
        when /soundcloud\.com/
          out = grind_soundcloud( url )
        when /open\.spotify\.com/
          out = grind_spotify( url )
      end

      return [out] unless out.empty?
    end

    out
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
            url = URI.parse("http://#{url.host}:#{url.port}#{res.header['location']}")
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
  

end
