require 'active_model'
require 'hooks'

module Kincurrent 
	class OwnerStream < Kincurrent::BaseEdge

		property :kind

    def owner
      self.start_vertex
    end

    def stream
      self.end_vertex
    end
    
	end #/Stream
end