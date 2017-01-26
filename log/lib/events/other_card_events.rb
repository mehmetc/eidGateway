class OtherCardEvents
  def initialize(queue)
    @queue = queue
  end

  def cardInserted(terminal, card)
    puts 'card inserted'
  end

  def cardRemoved(terminal, card)
    puts 'card removed'
  end

  def cardEventsInitialized(terminal, card)
    puts 'listening for non eID cards insert/remove events'
  end
end