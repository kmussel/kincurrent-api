require 'active_model'
require 'hooks'

module Kincurrent 
	class StreamEventTarget < Kincurrent::BaseEdge


		property :name
		property :kind

    def stream_event
      self.start_vertex
    end

    def target
      self.end_vertex
    end
    
	end #/Stream
end