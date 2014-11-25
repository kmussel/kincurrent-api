require 'active_model'
require 'hooks'

module Kincurrent 	
	class Post < Kincurrent::BaseModel

		property :id
    property :content
    property :creator_id
    property :stream_id
    has_n(:stream_events).from(:stream_event_target)
    has_n(:attachments).to(Kincurrent::Attachment)    
		has_one(:creator)



	end #/Stream
end