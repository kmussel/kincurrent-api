require 'oriented'

# Don't do this if we're raking
return if (File.basename($0) == "rake" && ENV["RAKE_ORIENTED"].blank?)
# if Sinatra::Base.development?
  Oriented.configure do |config|
    config.url = ENV["ORIENTDB_URL"] || "remote:localhost/kincurrent_development"
    config.pooled = true
    config.max_pool = 100
    config.username = 'kincurrent'
    config.password = 'family'
    config.enable_level2_cache = false
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

def Object.const_missing(const)
    req = require const.to_s.underscore
    klass = const_get(const)
    return klass if klass
end

Dir[File.dirname(__FILE__) + '/../app/models/*.rb'].each { |file| 
  begin
    load file
  rescue => e
    puts "RESUCING #{e.inspect} and name = #{e.name}"
  end
}


# Seem to only have to do this for edge classes
# require "#{Rails.root}/app/models/staff_data.rb"
# require "#{Rails.root}/app/models/player_data.rb"
Oriented::Registry.define do
  puts "**** Reloading ORIENTED ****"
  maincls = %w(BaseModel User Event Stream)
  # events = %w(Schedule Event Rule)
  # regs = %w(Registration RegistrationDivision RegistrationProduct Register RegistrationOrder RegistrationOrderItem)
  # forms = %w(Form FormField FormResponse FormResponseField)
  # other = %w(staff_for plays_for sanctions )

  (maincls).each do |cls|
    map "Kincurrent::#{cls}", cls
  end
end
