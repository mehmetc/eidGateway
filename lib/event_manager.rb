#encoding:UTF-8
require 'java'

require_relative 'java/commons-codec-1.10'
require_relative 'java/commons-eid-client-0.6.6'
require_relative 'java/commons-eid-consumer-0.6.6'
require_relative 'java/commons-logging-1.2'

java_import "be.fedict.commons.eid.client.CardAndTerminalManager"
java_import "be.fedict.commons.eid.client.BeIDCardManager"

require_relative 'events/beid_card_event'
require_relative 'events/other_card_events'
require_relative 'events/terminal_events'

require_relative 'event_queue_listener'

class EventManager
  attr_reader :managers

  def initialize(connections = [])
    @event_queue_listener = EventQueueListener.new(connections)
    cat_manager = CardAndTerminalManager.new
    beid_manager = BeIDCardManager.new(cat_manager)

    beid_manager.addBeIDCardEventListener(BeidCardEvent.new(@event_queue_listener.queue))
    beid_manager.addOtherCardEventListener(OtherCardEvents.new(@event_queue_listener.queue))
    cat_manager.addCardTerminalListener(TerminalEvents.new(@event_queue_listener.queue))

    @managers = [cat_manager, beid_manager]
    start
  end

  def start
    @event_queue_listener.start
    @managers.each do |manager|
      manager.start
    end
  end

  def stop
    @event_queue_listener.stop
    @managers.each do |manager|
      manager.stop
    end
  end

end

