require 'aws-sdk'
require 'fog'
require 'carrierwave'


ENV['S3_ACCESS_KEY'] = 'AKIAJPMJHWM7NJXUDVQA'
ENV['S3_SECRET_KEY'] = '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'


CarrierWave.configure do |config|
	config.fog_credentials = {
		:provider 				=> 'AWS',
		:aws_access_key_id 		=> 'AKIAJPMJHWM7NJXUDVQA',
		:aws_secret_access_key 	=> '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'
	}

	config.fog_directory 	= 'pluckio'
	config.fog_public 		= true
end