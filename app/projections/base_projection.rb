require 'json'

module Kincurrent
	class BaseProjection
		include DataMapper::Resource
    storage_names[:default] = 'projections'
    before :save, :generate_timestamp
    before :save, :generate_kin_id

		property :id, 				Serial
		property :last_id,				Integer, default: 0
		property :name,				String		
		property :updated_at, 		Integer		
		
		property :kin_id, String
	
		property :type, Discriminator, :unique => true
		
    # def to_json(options = {})
    #   props.to_json(options)
    # end

    protected

    def generate_timestamp
      self.updated_at = Time.now.utc.to_i
    end
    
    def generate_kin_id
      self.kin_id = UUIDTools::UUID.random_create.to_s unless self.kin_id
    end
		
		def self.register cls
		  p = cls.first_or_create()
		end

	end #/Model
end #/BaseModel