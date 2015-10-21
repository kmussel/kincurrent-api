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

    puts "QUEUE subscribe #{@queue.inspect}"

    @queue.subscribe(ack: false) do |meta, payload|
      # puts "Meta co = #{meta.correlation_id} and call id = #{that.call_id}"
      puts "inside the queue subscribe = #{payload}"
       if meta.correlation_id == that.call_id      
         that.response = JSON.parse(payload)
         that.lock.synchronize{that.condition.signal}
        end
    end    
  end

  def self.publish(*args)
    puts "SELF PUBLISH"
    r = self.new
    r.publish(*args)
  end

  def publish(message = "", route = "#", exchange = "events")
    puts "rpc publish message = #{message}"
    headers = {reply_to: @queue.name, correlation_id: self.call_id}
    lock.synchronize{
      if(Rabbitmq.instance.publish(message, route, exchange, headers))
        puts "finished rabbitmq instance publish"
        condition.wait(lock, 20)
      else
        puts "inside else of rabbitmq publish"
      end
    }
    puts "AFTER LOCK synchronize"
    @channel.queue_delete(@queue.name, false, false)

    response    
  end
end

