require 'pp'

module Ethereum::Connection::RPC
  def init_id
    @id = 0
  end

  def get_id
    @id += 1
    @id
  end

  def rpc_method(command, args: [])
    Oj.dump({jsonrpc: "2.0", method: command, params: args, id: get_id}, mode: :compat)
  end

  def call_method(method_name, args: [])
    method_name = lookup_method method_name
    payload = rpc_method method_name, args: args
    resp = call payload
    check_for_errors resp, method_name: method_name, args: args
    resp = parse resp
    # puts "RPC Response: #{resp}"
    resp
  end

  include ResponseParsing

  def check_for_errors(resp, method_name:, args: [])
    # TODO: improve
    if resp["error"]
      puts "ERROR:"
      puts "-"*50
      pp Oj.load resp
      puts "-"*50

      raise "ParseError: Method name: '#{method_name}' - Params: '#{args}'"
    end
    resp
  end

  include MethodLookup
end
