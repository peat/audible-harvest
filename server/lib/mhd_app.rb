require 'active_record'
require 'uri'
require 'json'
require 'net/http'

class MHDApp < Sinatra::Application

  def ensure_connections
    # connect to DB here
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end

  before do
    ensure_connections
    
    @errors = {} # empty error response. see #after for how this gets handled.
  end

  def errors?
    @errors.keys.length > 0
  end
  
  after do
    halt_with_errors! if errors?
  end

end

# load in all of the other .rb files in this directory
Dir[ File.join( File.dirname(__FILE__), '*.rb') ].each { |f| require f }
