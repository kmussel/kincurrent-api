require 'rubygems'
require 'data_mapper'

puts "INSIDE THE DATABASE LOAD"
# DataMapper::Logger.new($stdout, :debug)
# config = YAML.load_file(Pluck.root('database.yml'))
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:@localhost/kincurrent_development')

Dir[File.dirname(__FILE__) + '/../app/events/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/projections/*.rb'].each {|file| require file}

DataMapper.finalize
DataMapper.auto_upgrade!
