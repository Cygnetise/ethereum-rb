require_relative 'env'

module Ethereum
  class Eth

    attr_reader :interface

    def initialize(contracts_interface_name = "")
      @interface = load_interface contracts_interface_name

      @conn = if ENV["IPC"] == "1"
        Connection::IPC.new
      else
        Connection::HTTP.new
      end
    end

    def start_connection(&block)
      if block_given?
        @conn.start do
          init
          block.call self
        end
      else
        @conn.start
        init
      end
    end

    alias :start! :start_connection

    def init
      @coinbase = coinbase
      puts "Coinbase: #{@coinbase}"
      puts "Balance: #{balance}"
      puts "Block: #{block_get}"
      puts "Contracts: #{@interface.map{ |contr, interf| "#{contr}:#{interf[:address] || "<no_address>"}" }.join " - "}"
      puts "\n"
    end
  end

  # alias :RPC :Eth
  RPC = Eth
end



# demo mode

DEMO = ENV["DEMO_MODE"] == "1"
require_relative 'lib/misc/demo_mode.rb' if DEMO

puts "status: OK" unless [nil, ''].include? ENV["CHECK"]
