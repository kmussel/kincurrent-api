require 'oriented'

# Don't do this if we're raking
return if (File.basename($0) == "rake" && ENV["RAKE_ORIENTED"].blank?)
# if Sinatra::Base.development?
puts "THE ENV = #{ENV.inspect}"

  Oriented.configure do |config|
    config.url = ENV['ORIENTDB_URL'] || "remote:#{ENV['ORIENTDB_PORT_2424_TCP_ADDR']}/kincurrent_development" || "remote:localhost/kincurrent_development"
    config.pooled = true
    config.max_pool = 100
    config.username = ENV['ORIENTDB_ENV_ORIENTDB_USER'] || 'kincurrent'
    config.password = ENV['ORIENTDB_ENV_ORIENTDB_PWD'] || 'family'
    config.enable_local_cache = false
  end
# elsif Sinatra::Base.test?
#   Oriented.configure do |config|
#     config.url = "remote:localhost/kincurrent-test#{ENV['TEST_ENV_NUMBER']}"
#     config.pooled = true
#     config.max_pool = 100
#     config.username = 'kincurrent'
#     config.password = 'family'
#   end
# elsif Sinatra::Base.production?
#   puts "Configuration Production connection to #{ENV['ORIENTDB_URL']}"
#   Oriented.configure do |config|
#     config.pooled = true
#     config.max_pool = 200
#     config.min_pool = 20
#   end
# elsif Sinatra::Base.staging?
#   puts "Configuration Production connection to #{ENV['ORIENTDB_URL']}"
#   Oriented.configure do |config|
#     config.pooled = true
#     config.max_pool = 200
#     config.min_pool = 20
#   end
# end




# Seem to only have to do this for edge classes
# require "#{Rails.root}/app/models/staff_data.rb"
# require "#{Rails.root}/app/models/player_data.rb"
Oriented::Registry.define do
  puts "**** Reloading ORIENTED ****"
  vertextcls = %w(BaseModel User Group Event Stream Post StreamEvent Attachment)
  edgecls = %w(OwnerStream StreamEventTarget)

  (vertextcls).each do |cls|
    map "Kincurrent::#{cls}", cls
  end
  
  (edgecls).each do |cls|
    puts "THE CLS = #{cls.to_s.underscore}"
    map "Kincurrent::#{cls}", cls.to_s.underscore
  end
  
end
