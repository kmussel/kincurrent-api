require 'active_model'
require 'hooks'

module Kincurrent 
	class Invitation < Kincurrent::BaseModel


		property :name
    property :username
    property :email
    property :phone_number
        
    has_one(:creator).from(Kincurrent::User, :groups)
    has_one(:target).to(Kincurrent::Group)

    has_n(:stream_events).from(Kincurrent::StreamEvent, :target)

    
    def to_json(options={})
      js = props
      js[:recipient] = self.recipient.to_a
      js[:creator] = self.creator.to_json
      js.to_json(options)
    end

	end #/Stream
end
