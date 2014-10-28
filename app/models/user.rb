require 'active_model'
require 'hooks'

module Kincurrent 
	class User < Kincurrent::BaseModel

		attr_reader :password

		property :id
		property :username
		property :email
		property :password_digest
		property :password_salt
		property :api_key

		has_n(:bookmarks)
		has_n(:uploads)
		has_n(:streams).to(Kincurrent::Stream)

		def password=(password)
      @password         = password
      self.password_salt    = SecureRandom.uuid
      self.password_digest  = Digest::SHA1.hexdigest(@password + self.password_salt)

		end

		def self.authenticate(username, password)
      user = get(username: username)
      hash = Digest::SHA1.hexdigest(password + user.password_salt)
      user unless user.nil? || hash != user.password_digest
		end

	end #/User
end #/Pluck