require 'active_model'
require 'oriented'
require 'hooks'
require 'json'

module Kincurrent
	class BaseModel
    include Oriented::Vertex      
    include Hooks
    include ActiveModel::Validations

    define_hook :before_save
    before_save :generate_timestamp
    before_save :generate_kin_id

    
		property :kin_id		
		property :updated_at,	type: Fixnum
		property :created_at, type: Fixnum

		def rid
		  __java_obj.get_rid
		end
		
		def save
      run_hook :before_save
      super
    end

    def save!
      run_hook :before_save
      super
    end
    
    def to_json(options = {})
      props.to_json(options)
    end

    protected

    def generate_timestamp
      self.created_at = Time.now.utc.to_i unless created_at
      self.updated_at = Time.now.utc.to_i
    end
    
    def generate_kin_id
      self.kin_id = UUIDTools::UUID.random_create.to_s unless self.kin_id
    end
		
	end #/Model
end #/BaseModel