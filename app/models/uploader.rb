module Kincurrent
	class Uploader < CarrierWave::Uploader::Base
    include CarrierWave::RMagick		  
		storage :fog

    process :resize_to_fit => [300, 300]
    version :thumb do
        process :resize_to_fill => [200,200]
    end  
		def store_dir
		  puts "INSIDE store _dir"
		  puts "model = #{model.class.to_s}"
		  puts "mounted at = #{mounted_as}"
		  puts "kin_id = #{model.kin_id}"		  
		  puts "version = #{version_name}"		  		  
		  puts "and post #{model.post.inspect}"
			"#{model.kin_id}/#{version_name}"
		end
	end #/Uploader
end