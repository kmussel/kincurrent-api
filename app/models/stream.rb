require 'active_model'
require 'hooks'

module Kincurrent 
	class Stream < Kincurrent::BaseModel

		property :id
		property :name

    has_one(:group).from(:owner_stream)
		has_one(:event)
		has_one(:first_event).to(Kincurrent::StreamEvent)
		
		
		def insert_event(stream_event)
		  curevent = self.event
		  if curevent.nil?
		    self.first_event = stream_event
		  else
		    stream_event.previous = curevent
		  end
		  self.event = stream_event		    
		end


	end #/Stream
end