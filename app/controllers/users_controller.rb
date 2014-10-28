
module Kincurrent 
		class UsersController < BaseController

			namespace '/users' do 

        get '/' do 
          puts "INSIDE THIS GET"
          puts "THE CURRENT USER = #{current_user.inspect}"
          # Publisher.publish("user123", {test:"blah"})          
          json ({success:"HELLO THERE"})

        end
        
				get '/:userid/?' do
				  puts "THE USER ID = #{params[:userid]}"
					user = User.get!("#12:#{params[:userid]}")
					if user
						user.props.to_json
					else
						status 404
						json ({error: "User with id: #{params[:userid]} not found"})
					end
				end #/get /:userid

				post '/?' do
					username 	= params[:username]
					email		= params[:email]
					password	= params[:password]

					user = User.create(:username => username, :email => email, :password => password, :api_key => SecureRandom.uuid)
					if user.save!
						user.to_json :exclude => [:email, :password, :password_digest, :password_salt]
					else
						status 400
						json user.errors.to_hash
					end
				end #/post /

				post '/auth/?' do 
					username 	= params[:username]
					password 	= params[:password]
					user 		= User.authenticate(username, password)

					if user
						user.to_json :exclude => [:email, :password, :password_digest, :password_salt]
					else
						status 404
						json({status: "failure", message: "Invalid username and/or password"})
					end
				end

				put '/password/?' do 
					error 500 unless current_user

					if params[:password].length < 6
						status 400
						json({error: "Password must be at least 6 characters"})
					else
						if current_user.update :password => params[:password]
							json({status: "success", message: "Password updated"})
						else
							status 400
							json user.errors.to_hash
						end
					end
				end #/put password

				put '/apikey/?' do 
					error 500 unless current_user

					uuid = SecureRandom.uuid

					if current_user.update :api_key => uuid
						json({status: "success", message: "API Key has been updated", api_key: uuid})
					else
						status 400
						json current_user.errors.to_hash
					end
				end #/put apikey

				get '/?' do
					json (current_user)
				end #/get /

			end #/namespace '/user/'

	end #/Routes
end #/Pluck