module Kincurrent 
		class BaseController < Sinatra::Base
      helpers Roar::Sinatra		  
      register Sinatra::Namespace
  		configure :development do
  			register Sinatra::Reloader
  		end 
      set :views, File.expand_path('../../views', __FILE__) 
      
			def current_user
			  puts "NOW GETTING CURRENT USER"
        # puts "THE REQUEST = #{request.env.inspect}"
        # puts "THE KEY = #{request.env['HTTP_KINCURRENT_KEY']}"
				User.get!(api_key: request.env["HTTP_KINCURRENT_KEY"])
			end

			def url?(string)
				uri = URI.parse(string)

				%w(http https).include?(uri.scheme)
			rescue URL::BadURIError
				false
			rescue URL::InvalidURIError
				false
			end
			
			def authorized!
        halt 401, {error:"You must be logged in to perform this action"} unless current_user
      end
			  
			helpers do
			  def json_error(ex, code, errors = {})
          halt code, { 'Content-Type' => 'application/json' }, JSON.dump({
            message: ex.message
          }.merge(errors))
        end

        # Helper abort an request from an exception
        def halt_json_error(code, errors = {})
          json_error env.fetch('sinatra.error'), code, errors
        end
        
        # ActiveModel::Serializer helper
        def serialize(object, options = {})
          klass = options[:serializer] || object.active_model_serializer
          options[:scope] ||= nil
          serializer = klass.new(object, options)
          serializer.as_json
        end
            
      end
			
	end #/Controller
end #/Kincurent