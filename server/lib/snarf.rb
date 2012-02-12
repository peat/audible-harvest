class MHDApp

  get '/' do
    erb :'index'
  end

  get '/snarf.html' do
    erb :'snarf'
  end

  post '/snarf' do
    content_type :json

    record = {
      :person => params['person'],
      :track => params['track'],
      :artist => params['artist'],
      :provider => params['provider'],
      :origin => params['origin']
    }

    treasure = Treasure.new( record )
    treasure.save

    record.to_json
  end

end
