
module Kincurrent 
		class StreamsController < BaseController

			namespace '/streams' do 

        get '/?' do 
          puts "INSIDE THIS GET"
          puts "THE CURRENT USER = #{current_user.inspect}"
          Publisher.publish("user123", {test:"blah"})          
          json ({success:"HELLO THERE"})

        end
        
				get '/:streamID/?' do
				  puts "THE stream ID = #{params[:streamID]}"
					stream = Stream.get!(kin_id: params[:streamID])
					if stream
						stream.props.to_json
					else
						status 404
						json ({error: "Stream with id: #{params[:streamID]} not found"})
					end
				end #/get /:userid

				post '/?' do
					streamname 	= params[:name]

					stream = Stream.get_or_create(:name => streamname)
					if stream.save!
						stream.to_json :exclude => [:email, :password, :password_digest, :password_salt]
					else
						status 400
						json stream.errors.to_hash
					end
				end #/post /

				post '/:streamID/subscribe/?' do 
					error 500 unless current_user

          stream = Stream.get!(kin_id: params[:streamID])
          status 404 and return unless stream

				  if (Publisher.bind_queue("user.#{current_user.global_id}", stream.global_id))
            json({status:"success"})
					else
					  status 400
					  json {message:"Could Not Subscribe you at this time"}
				  end
				end #/put apikey

			end #/namespace '/streams/'

	end
end 