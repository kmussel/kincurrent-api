# module Kincurrent

# $LOAD_PATH.unshift('../app/models')
puts "REQUIRE FILES #{File.dirname(__FILE__)}"
require_relative '../config/boot.rb'
require 'uuidtools'
require 'march_hare'

class RabbitmqEventService

  DEFAULT_RETRY_TIMEOUT = 60

  def initialize(opts = {})
    puts "INIT RABBITMQ EVENT SERVICE"
    @retries_left = @max_retries = opts['max_retries'] || -1
    @retry_timeout = opts['retry_timeout'] || DEFAULT_RETRY_TIMEOUT
  end

  def start
    puts "INSIDE START EVENT SERVICE here #{Thread.current.inspect}"
    Thread.new { run }
  end

  def stop
    @connection.close if @connection && !@connection.closed?
  end
  
  def run
    begin
      # puts "INSIDE RUN EVENT SERVICE here #{Thread.current.inspect}"
      # # client = RabbitMQ::HTTP::Client.new(Settings.rabbitmq_api_url)
      # @connection ||= MarchHare.connect(uri: Settings.rabbitmq_url)    
      # @listen_channel = @connection.create_channel
      # @exch = @listen_channel.default_exchange
      # x = @listen_channel.topic('streams', durable: true)
      # q = @listen_channel.queue('kincurrent_event_subscriber', durable: true)
      # q.bind(x, routing_key: '#').subscribe(ack: true) do |meta, payload|
      #                 
      #   puts "INSIDE EVENT SUBSCRIBER #{Thread.current.inspect}"
      #   puts JRuby.reference(Thread.current).native_thread.id
      #   puts "META app_id = #{meta.app_id.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"        
      #   puts "META reply_to = #{meta.reply_to.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"    
      #   puts "META correlation_id = #{meta.correlation_id.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"        
      #   # sleep(2)
      #   # bindings = SinatraCache.cache.fetch("stream_bindings", expires_in: 1.minute) do
      #   #   bindings = client.list_bindings_by_source(Settings.rabbitmq_vhost, "streams")
      #   # end
      # 
      # 
      #   content = JSON.parse(payload)
      #   puts "** Message received #{meta.routing_key} and payload = #{content}"
      #   # puts "THE group  = #{Kincurrent::Group.get!(kin_id:content['kin_id']).inspect}"
      #   begin
      #      
      #     params = {routing_key: meta.reply_to, content_type: 'application/json', app_id: 'kincurrent', correlation_id: meta.correlation_id}
      #     puts "THE Params = #{params}"
      #     # @listen_channel.basic_publish('', meta.reply_to, true, params, {success:'true'}.to_json.to_java_bytes) if meta.reply_to
      #     @exch.publish({success:true}.to_json, params)  if meta.reply_to
      #     @listen_channel.ack(meta.delivery_tag)               
      #   rescue => e
      #     puts "Message Processing Error #{e.inspect}"
      #   end
      # end
      # 
      # @listen_channel2 = @connection.create_channel
      # @exch2 = @listen_channel2.default_exchange
      # x2 = @listen_channel2.topic('streams', durable: true)
      # q2 = @listen_channel2.queue('kincurrent_event_rpc_subscriber')      
      # q2.bind(x2, routing_key: 'group_show2').subscribe(ack: true) do |meta, payload|
      #                 
      #   puts "INSIDE EVENT GROUP SHOW SUBSCRIBER #{Thread.current.inspect}"
      #   puts JRuby.reference(Thread.current).native_thread.id
      #   puts "META group_show app_id = #{meta.app_id.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"        
      #   puts "META group_show reply_to = #{meta.reply_to.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"    
      #   puts "META group_show  correlation_id = #{meta.correlation_id.inspect}"        
      #   puts "----------------------------------"
      #   puts "----------------------------------"        
      #   sleep(10)
      #   # bindings = SinatraCache.cache.fetch("stream_bindings", expires_in: 1.minute) do
      #   #   bindings = client.list_bindings_by_source(Settings.rabbitmq_vhost, "streams")
      #   # end
      # 
      # 
      #   content = JSON.parse(payload)
      #   puts "** Message GROUP 2 received #{meta.routing_key} and payload = #{content}"
      #   # puts "THE group  = #{Kincurrent::Group.get!(kin_id:content['kin_id']).inspect}"
      #   begin
      #      
      #     params = {routing_key: meta.reply_to, content_type: 'application/json', app_id: 'kincurrent', correlation_id: meta.correlation_id}
      #     puts "THE Group 2 Params = #{params}"
      #     # @listen_channel.basic_publish('', meta.reply_to, true, params, {success:'true'}.to_json.to_java_bytes) if meta.reply_to
      #     @exch2.publish({success:true}.to_json, params)  if meta.reply_to
      #     @listen_channel2.ack(meta.delivery_tag)               
      #   rescue => e
      #     puts "Message Processing Error #{e.inspect}"
      #   end
      # end
      
    rescue => ex
      puts "** RABBITMQ EVENT SERVICE ERROR #{ex.inspect}"
      @retries_left -= 1 if @retries_left > 0
      if @retries_left != 0
        sleep(@retry_timeout)
        retry
      end
    end
  end
  
  
end

