
module Kincurrent 
	class UserProjection < Kincurrent::BaseProjection

	  register self
	  
    def user_created(event)
      content = event.content.inject({}) { |h, (k, v)| h[k] = v; h }
      streams = content.delete('streams')
      user = User.create(content)
      puts "THE USER = #{user.to_json}"
      puts "user commited = #{user.committed?}"
      puts "user id = #{user.__java_obj.identity.to_s}"
      streams.each do |s|
        stream = Stream.create(s)
        kind = ['timeline', 'actions'].include?(stream.name.downcase) ? stream.name.downcase : 'other'
        user.streams.create_relationship_to(stream, {kind: kind})
      end

      if user.valid?
        user.save! 
      end
      user
    end
	end
end
