require 'active_model'
require 'hooks'

module Kincurrent 
	class Group < Kincurrent::BaseModel


		property :name

    has_one(:creator).from(Kincurrent::User, :groups)
    has_n(:subscribers).from(Kincurrent::User, :subscribes_to)
    has_n(:streams).relationship(Kincurrent::OwnerStream, :owner_stream)
    has_n(:invitations)
    # has_one(:timeline).to(Stream)
    # has_one(:attachment_stream).to(Stream)
    
    def timeline
      (s = streams_rels.select{|m| m[:kind] == 'timeline'}.first) && s.stream
    end
    
    def attachment_stream
      (s = streams_rels.select{|m| m[:kind] == 'attachments'}.first) && s.stream
    end
    
    def to_json(options={})
      js = props
      js[:streams] = self.streams.to_a
      js[:creator] = self.creator.to_json
      js.to_json(options)
    end

	end #/Stream
end
