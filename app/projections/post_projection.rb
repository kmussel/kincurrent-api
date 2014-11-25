
module Kincurrent 
	class PostProjection < Kincurrent::BaseProjection
	  register self
	  
    def post_created(event)
      puts "INSIDE POST CREATED EVENT"
      puts "THE EVENT = #{event.inspect}"
      content = event.content.inject({}) { |h, (k, v)| h[k] = v; h }

      
      # creatorid = content.delete('creator_id')
      # streamid = content.delete('stream_id')
      attachments = content.delete('attachments') || []
      
      puts "THE ConTENT = #{content}"
      post = Post.create(content.except("rid"))
      puts "THE POST = #{post.inspect}"
      attachments.each do |a|
        post.attachments.create(a.except("rid"))
      end

      puts "THE POST CREATOR ID = #{post.creator_id}"
      user = User.get!(kin_id:post.creator_id)
      puts "THE USER = #{user.__java_obj.identity.to_s}"
      stream = Stream.get!(kin_id:post.stream_id)
      attachment_stream = stream.group.attachment_stream;
      
      # Create and Insert Stream Event into timeline stream
      so = StreamEvent.create
      post.stream_events.create_relationship_to(so, {kind: 'master'})
      stream.insert_event(so)
      so.save
      
      if post.attachments.count > 0
        so = StreamEvent.create
        post.stream_events.create_relationship_to(so, {kind: 'attachment'})
        attachment_stream.insert_event(so)
        so.save
      end
      
      # post.attachments.each do |att|
      #   so = StreamEvent.create
      #   att.stream_events.create_relationship_to(so, {kind: 'master'})
      #   attachment_stream.insert_event(so)
      #   so.save        
      # end

      
      # Create and Insert Stream Event into Creator's action_stream
      # post.reload!
      # user.reload!
      actionstream = user.action_stream
      se = StreamEvent.create
      post.stream_events.create_relationship_to(se, {kind: 'master'})
      actionstream.insert_event(se)
      
      
      # Create and Insert Stream Events into all subscribers of the group timeline
      stream.group.subscribers.each do |subscriber|
        se = StreamEvent.create
        post.stream_events.create_relationship_to(se, {kind: 'master'})
        timeline = subscriber.timeline
        timeline.insert_event(se)
        se.save
      end
      
      post.save!
      
      # group.creator = user
      # group.subscribers.create_relationship_to(current_user)
      # #       @group = Group.create(:name => groupname)
      # streams.each do |s|
      #   stream = Stream.create(s)
      #   kind = ['timeline', 'attachments'].include?(stream.name.downcase) ? stream.name.downcase : 'other'
      #   group.streams.create_relationship_to(stream, {kind: kind})
      # end
      # 
      # group.save!
      # timeline = Stream.create(:name => "Timeline")
      # @group.streams.create_relationship_to(timeline, {kind:"timeline"})
      # attachments = Stream.create(:name => "Attachments")
      # @group.streams.create_relationship_to(attachments, {kind:"attachments"})
    end
	end
end