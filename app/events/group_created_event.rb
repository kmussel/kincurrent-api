
module Kincurrent 
	class GroupCreatedEvent < Kincurrent::BaseEvent
    #     include DataMapper::Resource
		
		def initialize(attrs={})
		  super(attrs)
		  self.name = 'group_created'
		end
	end 
end