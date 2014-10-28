require 'rubygems'

puts "INSIDE THE BOOT"

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'

require_relative 'database'
Dir[File.dirname(__FILE__) + '/../app/services/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/controllers/*.rb'].each {|file| require file}