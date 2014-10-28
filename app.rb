puts "INSIDE CONFIG"
require 'config/boot'
require 'lib/sinatra_cache'

Bundler.require

$LOAD_PATH.unshift('./app/models')



module Kincurrent
	class App < Sinatra::Base
		configure :development do
			register Sinatra::Reloader
		end #/configure

    
    register Sinatra::Contrib
    register Sinatra::Namespace
    
    use SinatraCache

		use Rack::Deflater

    use Kincurrent::UsersController
    use Kincurrent::StreamsController    
    # use Routes::Bookmarks
    # use Routes::Uploads
	end #/API < Sinatra::Application
end #/module Kincurrent