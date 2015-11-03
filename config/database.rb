require 'rubygems'
require 'data_mapper'

puts "INSIDE THE DATABASE LOAD"
# DataMapper::Logger.new($stdout, :debug)
# config = YAML.load_file(Pluck.root('database.yml'))
ENV['DATABASE_URL'] = "postgres://#{ENV['DB_ENV_DB_USER']}:#{ENV['DB_ENV_DB_PASS']}@#{ENV['DB_PORT_5432_TCP_ADDR']}/#{ENV['DB_ENV_DB_NAME']}"

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:postgres@localhost/kincurrent_development')

Dir[File.dirname(__FILE__) + '/../app/events/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/../app/projections/*.rb'].sort.each {|file| require file}


DataMapper.finalize
DataMapper.auto_upgrade!

Dir[File.dirname(__FILE__) + '/../app/projections/*.rb'].sort.each {|file| load file; }
