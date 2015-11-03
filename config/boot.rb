require 'rubygems'

ENV['rabbitmq_url'] = "amqp://#{ENV['RABBIT_ENV_RABBITMQ_USER']}:#{ENV['RABBIT_ENV_RABBITMQ_PASS']}@rabbit:5672/#{ENV['RABBIT_ENV_RABBITMQ_VHOST']}"
ENV['rabbitmq_api_url'] = "http://#{ENV['RABBIT_ENV_RABBITMQ_USER']}:#{ENV['RABBIT_ENV_RABBITMQ_PASS']}@rabbit:15672"
# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'rmagick'
require_relative 'carrierwave.rb'

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

Bundler.require



require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'

$LOAD_PATH.unshift('./app/models') unless $LOAD_PATH.include?('./app/models')
$LOAD_PATH.unshift('./app/events') unless $LOAD_PATH.include?('./app/events')
$LOAD_PATH.unshift('./app/representers') unless $LOAD_PATH.include?('./app/representers')
#$LOAD_PATH.unshift('./app/controllers') unless $LOAD_PATH.include?('./app/controllers')
# $LOAD_PATH.unshift('./app/controllers') unless $LOAD_PATH.include?('./app/controllers')

Dir[File.dirname(__FILE__)+ "/../app/*"].each { |f| puts "THE dir = #{f}";  $LOAD_PATH.unshift(f) }
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
Dir[File.dirname(__FILE__) + '/../app/repositories/*.rb'].sort.each {|file| require file}