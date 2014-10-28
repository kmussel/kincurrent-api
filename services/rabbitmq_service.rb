# module Kincurrent

# $LOAD_PATH.unshift('../app/models')
puts "REQUIRE FILES #{File.dirname(__FILE__)}"
require_relative '../config/boot.rb'

require "rabbitmq/http/client"

class RabbitmqService

  DEFAULT_RETRY_TIMEOUT = 60

  def initialize(opts = {})
    @retries_left = @max_retries = opts['max_retries'] || -1
    @retry_timeout = opts['retry_timeout'] || DEFAULT_RETRY_TIMEOUT
  end

  def start
    Thread.new { run }
  end

  def stop
    @conn.close if @conn && !@conn.closed?
  end

  def run
    begin
      client = RabbitMQ::HTTP::Client.new(Settings.rabbitmq_api_url)

      @conn = MarchHare.connect(uri: Settings.rabbitmq_url)
      @ch = @conn.create_channel
      x = @ch.topic('streams', durable: true)
      q = @ch.queue('kincurrent_subscriber', durable: true)
      q.bind(x, routing_key: '#').subscribe(ack: true) do |meta, payload|

        bindings = SinatraCache.cache.fetch("stream_bindings", expires_in: 1.minute) do
          bindings = client.list_bindings_by_source(Settings.rabbitmq_vhost, "streams")
        end
        puts "** Message received #{meta.routing_key}"

        begin
          @ch.ack(meta.delivery_tag)
        rescue => e
          puts "Message Processing Error #{e.inspect}"
        end
      end
    rescue => ex
      puts "** RABBITMQ ERROR #{ex.inspect}"
      @retries_left -= 1 if @retries_left > 0
      if @retries_left != 0
        sleep(@retry_timeout)
        retry
      end
    end
  end
end

