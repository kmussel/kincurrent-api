module Kincurrent 
		class BaseController < Sinatra::Base
      register Sinatra::Namespace
  		configure :development do
  			register Sinatra::Reloader
  		end #/configure      
      
			def current_user
			  puts "NOW GETTING CURRENT USER"
			  puts "THE REQUEST = #{request.env.inspect}"
			  puts "THE KEY = #{request.env['HTTP_KINCURRENT_KEY']}"
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
			
	end #/Controller
end #/Kincurent