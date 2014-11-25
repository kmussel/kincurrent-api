require 'active_model'
require 'hooks'

module Kincurrent
	class User < Kincurrent::BaseModel
    
		attr_reader :password

		property :username
		property :email
		property :password_digest
		property :password_salt
		property :api_key

		has_n(:bookmarks)
		has_n(:uploads)
		has_n(:groups).to(Kincurrent::Group)	
		has_n(:subscribes_to).to(Kincurrent::Group)
    has_n(:streams).relationship(Kincurrent::OwnerStream, :owner_stream)

    validates :email, uniqueness: true
    validates :username, uniqueness: true
    
		def password=(password)
      @password         = password
      self.password_salt    = SecureRandom.uuid
      self.password_digest  = Digest::SHA1.hexdigest(@password + self.password_salt)

		end

		def self.authenticate(username, password)
      user = get!(username: username)
      puts "THE USER = #{user.inspect}"
      hash = Digest::SHA1.hexdigest(password + user.password_salt)
      user unless user.nil? || hash != user.password_digest
		end
		
		def timeline
      (s = streams_rels.select{|m| m[:kind] == 'timeline'}.first) && s.stream
    end
    
		def action_stream
      (s = streams_rels.select{|m| m[:kind] == 'actions'}.first) && s.stream
    end
		
		def subscribed_to_group?(g)
		  !!self.groups.select{|m| m[:kin_id] == g.kin_id}.first
		end
		
		def to_json(options={})
      js = props
      js[:streams] = self.streams.to_a
      js.to_json(options)
    end

	end #/User
end #/Pluck