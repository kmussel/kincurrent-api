require 'active_model'
require 'hooks'

module Kincurrent 
	class Event < Kincurrent::BaseModel

		attr_reader :password

		property :id
		property :name
		property :kind		

    has_one(:owner).to(Kincurrent::User)
		has_one(:obj)
		has_one(:next).to(Event)
		has_one(:previous).from(Event, :next)


	end #/Stream
end