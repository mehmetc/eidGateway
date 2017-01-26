class StreamController < GenericController
  get '/eid/?', provides: 'text/event-stream' do
    begin
    stream :keep_open do |out|
      settings.connections << out

      out << ": hello\n\n" unless out.closed?

      loop do
        out << ": heartbeat\n\n" unless out.closed?
        sleep 1
      end
    end
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end

  # this is a reflector anything sent to PUT /stream will be broadcasted to registered parties
  put '/?' do
    settings.connections.each do |out|
      if out.closed?
        settings.connections.delete(out)
      else
        out << "data: #{URI.escape(request.body.read)}\n\n"
      end
    end
    halt 204
  end
end