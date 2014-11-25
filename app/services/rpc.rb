require_relative 'rabbitmq.rb'

class Rpc
  attr_reader :connection
  attr_reader :lock, :condition
  attr_accessor :response, :call_id

  def initialize(opts = {})
    @lock      = Mutex.new
    @condition = ConditionVariable.new

    @channel = Rabbitmq.instance.channel
    @queue = @channel.queue('', auto_delete: true)

    self.call_id = UUIDTools::UUID.random_create.to_s    
    that = self

    @queue.subscribe(ack: false) do |meta, payload|
      # puts "Meta co = #{meta.correlation_id} and call id = #{that.call_id}"
       if meta.correlation_id == that.call_id      
         that.response = JSON.parse(payload)
         that.lock.synchronize{that.condition.signal}
        end
    end    
  end

  def self.publish(*args)
    r = self.new
    r.publish(*args)
  end

  def publish(message = "", route = "#", exchange = "events")
    headers = {reply_to: @queue.name, correlation_id: self.call_id}
    lock.synchronize{
      if(Rabbitmq.instance.publish(message, route, exchange, headers))
        condition.wait(lock, 20)
      end
    }
    @channel.queue_delete(@queue.name, false, false)

    response    
  end
end

