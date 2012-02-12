require './server/server.rb'

use Rack::Static, :urls => ["/css", "/images"], :root => "server/public"

run MHDApp
