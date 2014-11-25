
module Kincurrent 
	class PostCreatedEvent < Kincurrent::BaseEvent
    #     include DataMapper::Resource
		
		def initialize(attrs={})
		  super(attrs)
		  self.name = 'post_created'
		end
	end 
end