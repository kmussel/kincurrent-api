require 'active_model'
require 'oriented'
require 'hooks'

module Kincurrent 
	class BaseModel
    include Oriented::Vertex
    include Hooks

    define_hook :before_save
    before_save :generate_timestamp
    before_save :generate_global_id

		attr_reader :password

		property :global_id
		property :updated_at,	type: Fixnum
		property :created_at, type: Fixnum

		
		
		def save
      run_hook :before_save
      super
    end

    def save!
      run_hook :before_save
      super
    end

    protected

    def generate_timestamp
      self.created_at = Time.now.utc.to_i unless created_at
      self.updated_at = Time.now.utc.to_i
    end
    
    def generate_global_id
      self.global_id = UUIDTools::UUID.random_create.to_s unless self.global_id
    end
		
	end #/Model
end #/BaseModel