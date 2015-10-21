require 'active_model'
require 'hooks'

module Kincurrent 
	class StreamEvent < Kincurrent::BaseModel


		property :name
    property :creator_id
    
    has_one(:target).relationship(Kincurrent::StreamEventTarget, :stream_event_target)
    has_one(:next).to(Kincurrent::StreamEvent)    
    has_one(:previous).from(Kincurrent::StreamEvent, :next)
    has_one(:stream).from(Kincurrent::StreamEvent, :first_event)
    # has_one(:creator).from(Kincurrent::User, :groups)    
    # has_n(:subscribers).from(Kincurrent::User, :subscribes_to)
    # has_n(:streams).relationship(Kincurrent::GroupStream, :group_stream)
    # has_one(:timeline).to(Stream)
    # has_one(:attachment_stream).to(Stream)
    
    # def timeline
    #   (s = streams_rels.select{|m| m[:kind] == 'timeline'}.first) && s.stream
    # end
    # 
    # def attachment_stream
    #   (s = streams_rels.select{|m| m[:kind] == 'attachments'}.first) && s.stream
    # end
    
    def to_json(options={})
      js = props
      js[:target] = self.target.to_json
      # js[:creator] = self.creator.to_json
      js.to_json(options)
    end

	end #/Stream
end
