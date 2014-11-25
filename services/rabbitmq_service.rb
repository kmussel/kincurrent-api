# module Kincurrent

# $LOAD_PATH.unshift('../app/models')
puts "REQUIRE FILES #{File.dirname(__FILE__)}"
require_relative '../config/boot.rb'

class RabbitmqService

  DEFAULT_RETRY_TIMEOUT = 15

  def initialize(opts = {})
    puts "INIT RABBITMQ Projection SERVICE"
    @retries_left = @max_retries = opts['max_retries'] || -1
    @retry_timeout = opts['retry_timeout'] || DEFAULT_RETRY_TIMEOUT
  end

  def start
    # run_replay_server
    @event_thread = Thread.new { run }
    # @replay_event_thread = Thread.new { run_replay_server }    
  end

  def stop
    @conn.close if @conn && !@conn.closed?    
    # @event_thread.join
    # @replay_event_thread.join
  end

  
  def synchronize_projections
    last_processed_id = Kincurrent::BaseProjection.collect(&:last_id).min || 0
    Kincurrent::BaseEvent.all(:id.gte => last_processed_id, :order => [:id.asc]).each do |evt|
      puts "SYNCH evt = #{evt.to_json}"
      replay_exchange.publish(evt.to_json, routing_key:"#")
    end
  end
  
  def process_event(evt)
    result = {}
    content = JSON.parse(evt)        
    kin_event = Kincurrent::BaseEvent.get(content['id'])
    Kincurrent::BaseProjection.all.each do |p|
      # puts "contentname = #{content['name']} and P = #{p.inspect}"
      next if p.last_id >= kin_event.id
        
      begin          
        if p.respond_to?(content['name'])
          if (res = p.send(content['name'], kin_event))
            result = res
            # kin_event.processed_at = Time.now.utc.to_i
            # kin_event.save!
          end
        end
        p.last_id = kin_event.id
        p.save!
      rescue => e
        puts "HAD TO RESCUE #{e.inspect}"
      end

    end
    result
  end


  def run
    begin
      puts "INSIDE RUN here #{Thread.current.inspect}"
      # client = RabbitMQ::HTTP::Client.new(Settings.rabbitmq_api_url)
      # 
      # @conn ||= MarchHare.connect(uri: Settings.rabbitmq_url)
      # @channel = @conn.create_channel
      # @event_exchange = @channel.topic('events', durable: true)
      # 
      # puts "EVENT EXCH = #{@event_exchange.inspect}"
      # puts "------------------------"
      # puts "CHANNEL = #{@channel.inspect}"
      # q = channel.queue('kincurrent_subscriber', durable: true)
      # q.bind(event_exchange, routing_key: '#').subscribe(ack: true) do |meta, payload|
      #   
      #   puts "INSIDE RUN SUBSCRIBE here #{Thread.current.inspect}"
      #   # content = JSON.parse(payload)        
      #   # kin_event = Kincurrent::BaseEvent.get(content['id'])
      #   # # puts "KIN EVENT = #{kin_event.inspect}"
      #   result = {}
      #   # result = process_event(payload) || {}
      #   sleep(10)
      # 
      #   begin
      #     params = {routing_key: meta.reply_to, content_type: 'application/json', app_id: 'kincurrent', correlation_id: meta.correlation_id}
      #     # @listen_channel.basic_publish('', meta.reply_to, true, params, {success:'true'}.to_json.to_java_bytes) if meta.reply_to
      # 
      #     channel.default_exchange.publish(result.to_json, params)  if meta.reply_to
      #     channel.ack(meta.delivery_tag)
      #   rescue => e
      #     puts "Message Processing Error #{e.inspect}"
      #   end
      # end
      
      setup_post_subscriber
      
      puts "CREATING ANOTHER CHANNEL"
      setup_replay_subscriber
      
      # @conn2 ||= MarchHare.connect(uri: Settings.rabbitmq_url)      
      # @replay_channel = @conn.create_channel
      # @replay_exchange = @replay_channel.direct('replay_events', durable: true)    
      # puts "THEH REPLAY EXCHANGE = #{@replay_exchange.inspect}"  

      
      synchronize_projections()

    rescue => ex
      puts "** RABBITMQ ERROR #{ex.inspect}"
      @retries_left -= 1 if @retries_left > 0
      if @retries_left != 0
        sleep(@retry_timeout)
        retry
      end
    end
  end
  
  def setup_event_subscribers
    
  end
  
  def setup_post_subscriber
    
    q = post_channel.queue('kincurrent_subscriber', durable: true)
    q.bind(event_exchange, routing_key: 'post_created').subscribe(ack: true) do |meta, payload|
    
      puts "INSIDE RUN SUBSCRIBE POST here #{Thread.current.inspect}"
      # content = JSON.parse(payload)        
      # kin_event = Kincurrent::BaseEvent.get(content['id'])
      # # puts "KIN EVENT = #{kin_event.inspect}"
      result = process_event(payload) || {}

      if result.class.to_s == 'Kincurrent::Post'
        params = {routing_key: "#{result.group.kin_id}.post_created", content_type: 'application/json', app_id: 'kincurrent', correlation_id: meta.correlation_id}                    
        result.stream_events.each do |se|
          group_exchange.publish(StreamEventRepresenter.new(result).to_hash(), params)
        end
      end

      begin
        params = {routing_key: meta.reply_to, content_type: 'application/json', app_id: 'kincurrent', correlation_id: meta.correlation_id}
        # @listen_channel.basic_publish('', meta.reply_to, true, params, {success:'true'}.to_json.to_java_bytes) if meta.reply_to
        
        post_channel.default_exchange.publish(result.to_json, params)  if meta.reply_to
        post_channel.ack(meta.delivery_tag)
      rescue => e
        puts "Message Processing Error #{e.inspect}"
      end
    end
    
  end
  
  
  def setup_replay_subscriber
    q2 = replay_channel.queue('replay_subscriber', durable: true)
    q2.bind(replay_exchange, routing_key: '#').subscribe(ack: true) do |meta, payload|
      result = process_event(payload)
      replay_channel.ack(meta.delivery_tag)        
    end
  end
  
  
  private
  
  def connection
    @conn ||= MarchHare.connect(uri: Settings.rabbitmq_url)
  end
  
  def channel
    @channel ||= connection.create_channel
  end
  
  def event_exchange
    @event_exchange ||= channel.topic('events', durable: true)
  end
  
  def group_exchange
    @group_exchange ||= channel.topic('groups', durable: true)
  end
  
  def post_channel
    @post_channel ||= connection.create_channel
  end
    
  def replay_channel
    @replay_channel ||= connection.create_channel
  end

  def replay_exchange
    @replay_exchange ||= replay_channel.direct('replay_events', durable: true)
  end
    
end

