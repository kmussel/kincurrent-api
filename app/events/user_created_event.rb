
module Kincurrent 
	class UserCreatedEvent < Kincurrent::BaseEvent
    #     include DataMapper::Resource
		
		def initialize(attrs={})
		  super(attrs)
		  self.name = 'user_created'
		end
	end 
end