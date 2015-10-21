require_relative 'base_model.rb'
require_relative 'uploader.rb'

module Kincurrent 	
	class Attachment < Kincurrent::BaseModel

    property :name
    property :type
    property :creator_id

		has_one(:post).from(Kincurrent::Post, :attachments)
    has_n(:stream_events).from(:stream_event_target)
    
		mount_uploader :file, Uploader
		
		def file_name=(value)
		  write_uploader(:file, value)
		end

	end #/Stream
end