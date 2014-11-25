require 'json'

module Kincurrent
	class BaseEvent
		include DataMapper::Resource
    storage_names[:default] = 'events'
    # before :save, :generate_timestamp
    before :save, :generate_kin_id

		property :id, 				Serial
		property :content, Json			
		property :name,				String		
		property :processed_at, 		Integer		
		
		property :kin_id, String
	
		property :type, Discriminator
		
    # def to_json(options = {})
    #   props.to_json(options)
    # end

    protected

    def generate_timestamp
      self.created_at = Time.now.utc.to_i unless created_at
    end
    
    def generate_kin_id
      self.kin_id = UUIDTools::UUID.random_create.to_s unless self.kin_id
    end
		
	end #/Model
end #/BaseModel