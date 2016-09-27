require_relative 'env'

DEBUG = true
# DEBUG = false

# DEBUG_CONN = true
DEBUG_CONN = false


BLOCK_TIMEOUT = 3 # seconds - tx confirmation timeout (wait_for_block)


module Ethereum

  include Types
  include Interface
  include TxHandlers
  include ResponseParsing
  include Parsing
  include Utils

  def costz
    from = @coinbase
    contract = @interface[contract]
    contract_address = contract[:address]

    # ------ #
    # old    #
    # ------ #---------------------------------------------------#
    #
    # from = "0x433a8524aa6180f19f3d81f0a66454c0c5e644e2"
    # contract_address = "0xbaea7ac25443d20a45c5db3e322ef572bc34b57e"
    # method_sig = "update(uint256,bytes32,bytes32)"
    # data = "0x9507d39a0000000000000000000000000000000000000000000000000000000000000001"
    # ------ #---------------------------------------------------#


    resp = cost [{from: from, to: contract_address, data: data}]
    raise resp.inspect
    resp
  end

  def receiptz(hash)
    receipt_hash = hash
    # receipt_hash = "0x3c367eda3be413b03faedc8113bf169f4c8cc61fde7f8aa2248616395adcf331"

    resp = receipt [receipt_hash]
    resp = parse resp

    resp
  end

  # eth_getTransactionReceipt


  # TODO move outside
  def block_get
    res = parse block
    # puts "Block: #{res}"# if DEBUG
    res
  end

  def do_write
    raise "of course!".inspect
    resp = get
    puts "EntriesKV.get(1): #{resp.inspect}"

    last_block = block_get
    resp = writez
    puts "EntriesKV.update(1, x, x): #{resp} (receipt)"

    resp = get
    wait_for_change(resp) do
      get
    end

    # wait_for_block last_block
    # puts "block found!"


    resp = get
    puts "EntriesKV.get(1): #{resp.inspect}"

    puts "\n"
    # sleep 2

    resp = get
    puts "EntriesKV.get(1): #{resp.inspect}"

    # last_block = block_get
    # resp = writez2
    # puts "EntriesKV.update(1, y, y): #{resp} (receipt)"
    # resp = get
    # wait_for_change(resp) do
    #   get
    # end
    # puts "change ok"
    # # wait_for_block last_block
    # # puts "block found!"

    resp = get
    puts "EntriesKV.get(1): #{resp.inspect}"

    puts "\n"
    # sleep 2
    # receipt_check receipt_hash
  end


  include Interface


  def set(contract:, method:, params: [])
    from = @coinbase
    contract = @interface[contract]
    contract_address = contract[:address]

    method_name = method
    method = contract[:methods].find{ |m| m["name"] == method_name.to_s }
    raise "Cannot contract method '#{method_name}' (contract: #{contract[:class_name]})" unless method
    method = sym_keys method
    sig = method[:methodId]
    # raise sig.inspect
    raise "Cannot find sha3 signature for method '#{method}'" unless sig

    # TODO: re-check
    params = ["00000000000000000000000000000000000000000000000000000000000000#{params.first}"]
    data = "#{sig}#{params.join}"
    # raise data.inspect

    gas = "0x8e52"


    resp = write [{from: from, to: contract_address, data: data, gas: gas}]
    resp = parse resp

    resp
  end

  def get(contract:, method:, params: [])
    from = @coinbase
    contract = @interface[contract]
    contract_address = contract[:address]

    method_name = method
    method = contract[:methods].find{ |m| m["name"] == method_name.to_s }
    raise "Cannot contract method '#{method_name}' (contract: #{contract[:class_name]})" unless method
    method = sym_keys method
    sig = method[:methodId]
    # raise sig.inspect
    raise "Cannot find sha3 signature for method '#{method}'" unless sig

    # method_sig = "get(uint256)"
    # sig = method_sig
    # sig = sha_sig sig
    # sig = "0x#{sig}"

    # TODO: fixme
    params = ["000000000000000000000000000000000000000000000000000000000000000#{params.first}"]
    params = []

    # raise contract.inspect
    outputs = method[:outputs]

    data = "#{sig}#{params.join}"

    puts "Calling #{contract[:class_name]}.#{method_name}(#{params.join ", "})"
    resp = read [{from: from, to: contract_address, data: data}]
    # /entries_kv/get?id=1
    resp = parse resp
    puts "Resp (raw): #{resp}" if DEBUG

    resp = parse_types resp, outputs: outputs
    puts "Resp (types): #{resp}" if DEBUG


    output = parse_get_resp resp, outputs: outputs
    puts "Resp: #{output.inspect}" if DEBUG
    # raise output.inspect
    output
  end

  # TODO
  def parse_types(resp, outputs:)
    if resp.is_a? Array
      values = resp
      values.map.with_index do |value, idx|
        output = outputs[idx]
        parse_type_read value, type: output["type"]
      end
    else
      output = outputs.first
      parse_type_read resp, type: output["type"]
    end
  end

  def sset(contract:, method:, params: [])
    last_block = block_get
    set contract: contract, method: method, params: params
    if wait_block last_block
      true
    else
      puts "retrying"
      sset contract: contract, method: method, params: params
    end
  end

  def main
    @interface = load_interface

    # TODO: add pipelining

    # @conn = Connection::HTTP.new
    @conn = Connection::IPC.new
    @conn.start do
      @coinbase = coinbase
      puts "Coinbase: #{@coinbase}"
      puts "Balance: #{balance}"
      puts "Block: #{block_get.hex}"
      puts "Contracts: #{@interface.map{ |contr, interf| "#{contr}:#{interf[:address]}" }.join " - "}"
      puts "\n"

      # 12.5 transactions per second
      50.times do
        get contract: :op_return, method: :data, params: []
        puts "op_return.data() done, transaction finished (outer scope)"


        resp = sset contract: :op_return, method: :set, params: [44]
        # raise "WRITE RESP: #{resp}"

        resp = get contract: :op_return, method: :data, params: []
        puts "op_return.data(): #{resp.inspect}"

        resp = sset contract: :op_return, method: :set, params: [45]

      end

      # sleep 2

      # sig = "get(uint256)"
      # sig = sha_sig sig

      # 20.times do
      # resp = do_write
      # end
      # unless resp
      #   resp = do_write
      # end
    end

    true


    # request:
    #
    # curl localhost:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0", "method":"eth_call", "params":[{"from": "0x433a8524aa6180f19f3d81f0a66454c0c5e644e2", "to": "0xbaea7ac25443d20a45c5db3e322ef572bc34b57e", "data": "0x9507d39a0000000000000000000000000000000000000000000000000000000000000001"}], "id":1}'
    #
    #
    # response:
    # {"jsonrpc":"2.0","result":"0x000000000000000000000000000000000000000000000000000000000000000161736400000000000000000000000000000000000000000000000000000000006173640000000000000000000000000000000000000000000000000000000000","id":1}
    #
  end

  # TODO: use define_method

  def coinbase
    res = @conn.call_method "coinbase"
    parse res
  end

  def read(args=[])
    puts "ETH read: #{args.join ", "}" if DEBUG_CONN
    @conn.call_method "read", args: args
  end

  def write(args=[])
    puts "ETH write: #{args.join ", "}" if DEBUG_CONN
    p args.first[:data]
    @conn.call_method "write", args: args
  end

  def cost(args=[])
    @conn.call_method "cost", args: args
  end

  def receipt(args=[])
    @conn.call_method "receipt", args: args
  end

  def block(args=[])
    @conn.call_method "block", args: args
  end

  def balance(args=[])
    args = [coinbase] if args.empty?
    res = @conn.call_method "balance", args: args
    parse res
  end


  # def call(payload)
  #   # TODO: add pipelining
  #   uri = URI "http://#{RPC_HOST}:#{RPC_PORT}/"
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   header = {'Content-Type' => 'application/json'}
  #   req = Net::HTTP::Post.new uri, header
  #   req.body = payload
  #   resp = http.request req
  #   return resp.body
  # end

end



# command = "eth_coinbase"
# args = []
# payload = { jsonrpc: "2.0", method: command, params: args, id: get_id }
# resp = call payload.to_json
# p resp

# ---

include Ethereum

main

# ---

# payload = { jsonrpc: "2.0", method: "eth_coinbase", params: [], id: 1 }.to_json
# call_ipc payload
