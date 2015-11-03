require 'aws-sdk'
require 'fog'
require 'carrierwave'
require 'carrierwave/processing/rmagick'

ENV['S3_ACCESS_KEY'] = 'YOUR ACCESS KEY'
ENV['S3_SECRET_KEY'] = 'YOUR SECRET KEY'


CarrierWave.configure do |config|
	config.fog_credentials = {
		:provider 				=> 'AWS',
		:aws_access_key_id 		=> ENV['S3_ACCESS_KEY'],
		:aws_secret_access_key 	=> ENV['S3_SECRET_KEY']
	}

	config.fog_directory 	= 'yourdir'
	config.fog_public 		= true
end
