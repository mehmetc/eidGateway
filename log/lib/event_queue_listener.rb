require 'thread'
require 'json'

class EventQueueListener
  attr_reader :queue_active, :queue, :queue_listener, :connections

  def initialize(connections = [])
    @queue_active = false
    @queue = Queue.new
    @connections = connections
  end

  def start
    @queue_active = true
    listen
  end

  def stop
    @queue_active = false
    @queue_listener.join
  end

  private
  def listen
    @queue_listener = Thread.new do |t|
      while @queue_active
        begin
          data = @queue.pop
          puts "sending message to #{@connections.length} connections"
          @connections.each do |out|
            if out.closed?
              @connections.delete(out)
            else
              puts 'sending message'
              out << "data: #{data.to_json}\n\n"
            end
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.join("/n")
          puts "unable to send message"
        end
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("/n")
    puts "unable to send message 2"
  end
end