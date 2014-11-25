puts "INSIDE CONFIG"

require 'config/boot'

require 'lib/sinatra_cache'
Dir[File.dirname(__FILE__) + '/app/representers/*.rb'].each {|file| require file}

Bundler.require


module Kincurrent
	class App < Sinatra::Base
		configure :development do
		  Sinatra::Base.reset!
			register Sinatra::Reloader
		end #/configure

    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :views, Proc.new { File.join(root, "app/views") }
    
    register Sinatra::Contrib
    register Sinatra::Namespace
    
    use SinatraCache

		use Rack::Deflater


    use Kincurrent::HomeController    
    use Kincurrent::UsersController
    use Kincurrent::GroupsController
    use Kincurrent::StreamsController    
    use Kincurrent::StreamEventsController
    # use Routes::Bookmarks
    # use Routes::Uploads

	end #/API < Sinatra::Application
end #/module Kincurrent