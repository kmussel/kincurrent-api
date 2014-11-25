require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
require_relative 'carrierwave.rb'


Bundler.require

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'

$LOAD_PATH.unshift('./app/models') unless $LOAD_PATH.include?('./app/models')
$LOAD_PATH.unshift('./app/events') unless $LOAD_PATH.include?('./app/events')
$LOAD_PATH.unshift('./app/representers') unless $LOAD_PATH.include?('./app/representers')

require_relative 'database'
require_relative 'orientdatabase'
require_relative '../lib/kincurrent'

def Object.const_missing(const)
    req = require const.to_s.underscore
    klass = const_get(const)
    return klass if klass
end

module Kincurrent
  def self.const_missing(const)
    req = require const.to_s.underscore
    klass = const_get(const)
    return klass if klass
  end
end

Dir[File.dirname(__FILE__) + '/../app/validators/*.rb'].each {|file| require file}


Dir[File.dirname(__FILE__) + '/../app/models/*.rb'].each { |file| 
  begin
    require file
  rescue => e
    puts "RESCUEING #{e.inspect} and name = #{e.name}"
  end
}
Dir[File.dirname(__FILE__) + '/../app/views/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/services/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/controllers/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/repositories/*.rb'].each {|file| require file}