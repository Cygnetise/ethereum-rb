module EthereumRb::Connection; end

require_relative 'rpc'

module EthereumRb::Connection
  
  class IPC
    include RPC
    
    def initialize
      init_id
    end
    
    def start(&block)
      check_ipc_file!
      @socket = UNIXSocket.new IPC_PATH
      if block_given?
        block.call self
        @socket.close
      end
      @socket
    end
    
    def call(payload)
      # puts "Payload: #{payload}"
      @socket.puts payload
      # msg =  @socket.recv 1000000
      # FIXME: there's probably a better way to do this
      msg =  @socket.recv 10000000
      # msg += @socket.recv 10000000
      msg
    end
    
    def close
      @socket.close
    end
    
    private
    
    def check_ipc_file!
      raise "IPC file not found at path '#{IPC_PATH}' - Make sure parity/geth is running? ('cd parity; ./run')" unless  File.exists? IPC_PATH
    end
  end
  
  class HTTP
    include RPC
    
    def initialize
      init_id
      url = "http://#{RPC_HOST}:#{RPC_PORT}"
      @uri = URI url
      @default_headers = {'Content-Type' => 'application/json'}
    end

    def call(payload)
      puts "payload: #{payload}" if ETH_LOG
      resp = ::Typhoeus.post(@uri, body: payload, headers: @default_headers)
      if resp.success?
        resp.response_body
      else
        puts "error response: #{resp.response_body}" if ETH_LOG
        Oj.dump({ error: resp.return_message })
      end
    end

  end

end
