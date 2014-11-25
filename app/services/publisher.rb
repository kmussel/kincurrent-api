class Publisher
  def self.publish(message = "", route = "#", exchange = "events")
    channel.confirm_select
    x        = channel.topic(exchange, durable: true)
    x.publish(message,
              routing_key: route, persistent: true,
              content_type: 'application/json',
              app_id: 'kincurrent'
             )
    confirmed = channel.wait_for_confirms
    fail PublisherError unless confirmed
    confirmed
  rescue => e
    puts "PUBLISH EXCEPTION = #{e.inspect}"
    false
  end

  def self.bind_queue(queue_name, routing_key)
    x    = channel.topic("streams", :durable => true)
    q    = channel.queue(queue_name, :durable => true).bind(x, :routing_key => routing_key)
    q
  rescue => e
    puts "BIND EXCEPTION = #{e.inspect}"
    false
  end        
  #   curl -i -u guest:guest -H "content-type:application/json"     -XGET -d'{"type":"direct","durable":true}' http://localhost:15672/api/exchanges/dev/streams/bindings/source
  #   x.publish("THIS IS A TEST", :routing_key => 'FamilyStream')
  #   x = ch.topic("streams", :durable => true)
  #   q = ch.queue('').bind(x, :routing_key => '#')
  #   q.subscribe do |metadata, payload|
  #     puts "metadata = #{metadata.inspect}"
  #     puts "payload: #{payload}"
  #   end
  #   
  #   q1 = ch.queue("users.#{username}", :durable => true).bind(x, :routing_key => "FamilyStream")
  #   q1.subscribe do |metadata, payload|
  #     puts "metadata = #{metadata.inspect}"
  #     puts "payload: #{payload}"
  #   end
  #   
  #   x    = MarchHare::Exchange.new(ch,  name, :type => :fanout)
  # end
  
  def self.channel
    @channel ||= connection.create_channel
  end

  def self.connection
    @connection ||= MarchHare.connect(uri: Settings.rabbitmq_url)
  end

  def self.close
    @connection.close unless @connection.closed?
    @connection = nil
    @channel = nil
  end
end

class PublisherError < StandardError; end
