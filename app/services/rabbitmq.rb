require 'singleton'

class Rabbitmq
  include Singleton
  
  def self.start(options)
     instance.options = options
     instance.start
   end
  
  def start
    channel
  end
  
  def connection
    @connection ||= MarchHare.connect(uri: Settings.rabbitmq_url, host: Settings.rabbitmq_host)
  end
  
  def channel
    Thread.current[:rabbitmq_channel] ||= connection.create_channel
  end
  
  def self.publish(message = "", route = "#", exchange = "streams", headers = {})
    instance.publish(message, route, exchange, headers)
  end
  
  def publish(message = "", route = "#", exchange = "streams", headers = {})
    params =  {routing_key: route, persistent: true, content_type: 'application/json', app_id: 'kincurrent' }.merge(headers)
    puts "PARAMS = #{params.inspect}"
    puts "message = #{message}"
    channel.confirm_select
    # x = channel.exchange_declare(exchange, 'topic', true)        
    x = channel.topic(exchange, durable: true)    
    x.publish(message, params)
    # channel.basic_publish(exchange, route, true, params, message.to_java_bytes)

    confirmed = channel.wait_for_confirms
    puts "CONFIRMED = #{confirmed}"
    fail PublisherError unless confirmed
    confirmed
  rescue => e
    puts "PUBLISH EVENT SERVICE EXCEPTION = #{e.inspect}"
    false
  end
    
end


# class PublisherError < StandardError; end
