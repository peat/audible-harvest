class MHDApp

  get '/' do
    erb :'index'
  end

  get '/snarf.html' do
    erb :'snarf'
  end

  post '/snarf' do
    content_type :json

    person = params['person']
    track = params['track']
    artist = params['artist']
    provider = params['provider']
    origin = params['origin']

    { :person => person, :track => track, :provider => provider, :origin => origin }.to_json
  end

end
