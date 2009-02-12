require 'socket'
require 'pp'

module FreeSwitcher
  require File.join(File.dirname(__FILE__), 'event') unless FreeSwitcher.const_defined?("Event")
  class EventSocket
    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    # Send a command and return response
    def send(cmd)
      @socket.send("#{cmd}\n\n",0)
      response
    end

    # Send a command, do not return response
    def <<(cmd)
      @socket.send("#{cmd}\n\n",0)
    end

    # Grab result from command
    def result
      headers, body = {}, ""
      until line = @socket.gets and line.chomp.empty?
        if (kv = line.chomp.split(/:\s+/,2)).size == 2
          headers.store *kv
        end
      end
      if (content_length = headers["Content-Length"].to_i) > 0
        debug "content_length is #{content_length}, grabbing from socket"
        body << @socket.read(content_length)
      end
      headers.merge("body" => body)
    end
    
    # Scrub result into a hash
    def response
      result
    end

    def debug(msg)
      $stdout.puts msg
      $stdout.flush
    end

  end
end