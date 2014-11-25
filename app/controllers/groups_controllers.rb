
module Kincurrent 
		class GroupsController < BaseController
      set :views, File.expand_path('../../views/groups', __FILE__) #Proc.new { File.join(settings.views, "groups") }		  

			namespace '/groups' do 

        get '/?' do 
          status 404 and return unless current_user
          # stream_id = current_user.subscribes_to.all
          # results = StreamEventRepository.get_stream_events(stream_id, {startrid: params[:startrid]})
          roar current_user.subscribes_to.to_a
          # json ({success:"HELLO THERE"})

        end
        
				get '/:groupID/?' do
					@group = Group.get!(kin_id: params[:groupID])
					if @group
            # Kincurrent::GroupRepresenter.new(@group).to_json
            # @group.extend(Kincurrent::GroupRepresenter).to_json
            roar @group, create: true
            # jbuilder :show
					else
						status 404
						json ({error: "Group with id: #{params[:groupID]} not found"})
					end
				end #/get /:userid

				post '/?' do
          authorized!
				  begin
  					groupname 	= params[:name]
            @group = Group.get(name: groupname)
            if @group
  					  halt 400, {success:false, errors:["Group with the name #{groupname} already exists"]}.to_json
  					end
					
  					@group = Group.create(:name => groupname)
  					@group.creator = current_user
  					timeline = Stream.create(:name => "Timeline")
  					@group.streams.create_relationship_to(timeline, {kind:"timeline"})
  					attachments = Stream.create(:name => "Attachments")
  					@group.streams.create_relationship_to(attachments, {kind:"attachments"})
  					if @group.save
  					  groupjson = roar @group
  					  ge = Kincurrent::GroupCreatedEvent.create(content:groupjson)
				      Rabbitmq.publish(ge.to_json, "group_created");
  						groupjson
  					else
  						status 400
  						json @group.errors.to_hash
  					end
  				rescue => e
  				  puts "EXCEPTION = #{e.inspect}"
          end
				  
				end #/post /

				post '/:groupID/subscribe/?' do 
					error 500 unless current_user

          group = Group.get!(kin_id: params[:groupID])
          status 404 and return unless group && group.timeline
          group.subscribers.create_relationship_to(current_user)
          # Publisher.publish({stream}, "user_subscribed")
				  if (Publisher.bind_queue("user.#{current_user.global_id}", stream.global_id))
            json({status:"success"})
					else
					  status 400
					  json {message:"Could Not Subscribe you at this time"}
				  end
				end #/put apikey
				
				
				post '/:groupID/timeline/?' do 
					error 500 unless current_user

          group = Group.get!(kin_id: params[:groupID])
          status 404 and return unless group && group.timeline
          timeline = group.timeline          
          error 404 unless current_user.subscribed_to_group?(group)

          # group.subscribers.create_relationship_to(current_user)
          # Publisher.publish({stream}, "user_subscribed")

          @post = Post.create(content: params[:content], creator_id: current_user.kin_id, stream_id: timeline.kin_id)
          atch = @post.attachments.create(name: "test2", type: params[:fileUpload][:type], file: params[:fileUpload])
          
          if @post.save && @post.valid?
            postjson = roar @post, create: true
					  ge = Kincurrent::PostCreatedEvent.create(content:postjson)
			      Rabbitmq.publish(ge.to_json, "post_created");
						postjson
					else
						status 400
						json @post.errors.to_hash
					end
  					
          # puts "THE params = #{params.inspect}"
          # u = Attachment.create(name: "test2", type: params[:fileUpload][:type])
          # u.file = params[:fileUpload] #[:tempfile]
          # u.save!
          # puts "THE U = #{u.props}"
          # 
          # puts "THE FILE = #{u.file}"
          # postjson = jbuilder :create, views:'app/views/posts/'
          # pe = Kincurrent::PostCreatedEvent.create(content: postjson)
          #           if(Rabbitmq.publish(pe.to_json, "post_created"))
          #           # if (Publisher.bind_queue("user.#{current_user.global_id}", stream.global_id))
          #             postjson
          # else
            #             status 400
            # json({message:"Could Not Create Post at this time"})
          # end
				end #/put apikey

			end #/namespace '/streams/'

	end
end