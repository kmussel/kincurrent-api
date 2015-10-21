
module Kincurrent 
	class GroupProjection < Kincurrent::BaseProjection
	  register self
	  
    def group_created(event)
      puts "INSIDE GROUP CREATED EVENT"
      content = event.content.inject({}) { |h, (k, v)| h[k] = v; h }
      creator = content.delete('creator')
      streams = content.delete('streams')
      
      group = Group.create(content)
      user = User.get!(kin_id:creator['kin_id'])
      group.creator = user
      group.subscribers.create_relationship_to(user)
      #       @group = Group.create(:name => groupname)
      streams.each do |s|
        stream = Stream.create(s)
        kind = ['timeline', 'attachments'].include?(stream.name.downcase) ? stream.name.downcase : 'other'
        group.streams.create_relationship_to(stream, {kind: kind})
      end
      
      group.save!
      # timeline = Stream.create(:name => "Timeline")
      # @group.streams.create_relationship_to(timeline, {kind:"timeline"})
      # attachments = Stream.create(:name => "Attachments")
      # @group.streams.create_relationship_to(attachments, {kind:"attachments"})
    end
	end
end