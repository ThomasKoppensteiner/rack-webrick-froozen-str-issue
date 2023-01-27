# frozen_string_literal: true

require "rack"
require "webrick"
require "net/http/persistent"

HOST = 'localhost'
PORT = 8080

class App
  def call(env)
    begin
      if env["PATH_INFO"] == "/__identify__"
        [200, {}, ["foo"]]
      else
        [404, {}, []]
      end
    rescue StandardError => e
      @error = e unless @error
      raise e
    end
  end
end

def boot
  @server_thread = Thread.new { run_server }
  Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
rescue Timeout::Error
  raise "Rack application timed out during boot"
else
  puts "OK"
end

def run_server
  app = App.new
  opts = { Host: HOST, Port: PORT, AccessLog: [], Logger: WEBrick::Log::new(nil, 5) }

  server = Rack::Handler::WEBrick.run(app, **opts)
end

def responsive?
  return false if @server_thread && @server_thread.join(0)
  res = get_identity
  if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    return res.body == @app.object_id.to_s
  end
rescue SystemCallError
  return false
rescue EOFError
  return false
end

def get_identity
  http = Net::HTTP.new(HOST, PORT)

  http.get('/__identify__')
end

boot
