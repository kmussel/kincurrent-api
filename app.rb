require 'rubygems'
require 'json'
require 'bundler'
require 'securerandom'
require 'settingslogic'

Bundler.require

require 'sinatra/base'
require 'sinatra/contrib'

require 'sinatra/reloader'

$LOAD_PATH.unshift('./app/models')

Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/app/services/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/app/controllers/*.rb'].each {|file| require file}



module Kincurrent
	class App < Sinatra::Base
		configure :development do
			register Sinatra::Reloader
		end #/configure

    register Sinatra::Contrib
    register Sinatra::Namespace

		use Rack::Deflater
    # use Routes::Main
    use Kincurrent::UsersController
    use Kincurrent::StreamsController    
    # use Routes::Bookmarks
    # use Routes::Uploads
	end #/API < Sinatra::Application
end #/module Kincurrent