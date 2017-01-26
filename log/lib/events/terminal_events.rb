class TerminalEvents
  def initialize(queue)
    @queue = queue
  end

  def terminal_attached(terminal)
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
    puts "CardTerminal #{terminal.name} attached"
  end

  def terminal_detached(terminal)
    @queue << {
        terminal: {
            name: terminal.name,
            attached: false
        },
        card: {
            present: terminal.is_card_present,
            data: {}
        }
    }
    puts "CardTerminal #{terminal.name} detached"
  end


  def terminal_events_initialized
    pusts 'listening to terminals being attached/detached'
  end
end