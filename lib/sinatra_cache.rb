require 'active_support/cache/torque_box_store'
class SinatraCache < Sinatra::Base
  set :cache, ActiveSupport::Cache::TorqueBoxStore.new
end