require 'lib/be_id'
class BeidCardEvent
  def initialize(queue)
    @queue = queue
  end

  def eIDCardRemoved(terminal, card)
    @queue << {
        terminal: {
            name: terminal.name,
            attached: true
        },
        card: {
            present: terminal.is_card_present,
            data: {}
        }
    }
    puts "eID card removed from '#{terminal.name}'"
  end

  def eIDCardInserted(terminal, card)
    beid = BeID.new(card)

    @queue << {
        terminal: {
            name: terminal.name,
            attached: true
        },
        card: {
            present: terminal.is_card_present,
            data: {identity: beid.identity,
                   address: beid.address,
                   photo: beid.photo}
        }
    }

    puts "eID card inserted into '#{terminal.name}' is from #{beid.identity[:name]} #{beid.identity[:first_name]}"
  end

  def eIDCardEventsInitialized(terminal, card)
    puts 'Listening for eID card insert/remove events'
  end
end


