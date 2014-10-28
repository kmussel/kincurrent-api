require 'active_model'
require 'hooks'

module Kincurrent 
	class Stream < Kincurrent::BaseModel

		attr_reader :password

		property :id
		property :name

    has_one(:owner).from(Kincurrent::User, :streams)
		has_one(:event)
		has_one(:first_event)



	end #/Stream
end