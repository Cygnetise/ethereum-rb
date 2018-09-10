# demo usage

require_relative '../../ethereum-rb'

ETH = EthereumRb::Eth.new

ETH.start do |eth|
  eth.set contract: :op_return, method: :set, params: ['{ "message": "hello world" }']
  val = eth.get contract: :op_return, method: :data

  puts "Finished - got: #{val}"
end

# demo key-value contract:
#
# eth.set contract: :key_value, method: :set, params: ["hello", '{ "message": "hello world" }']
# val = eth.get contract: :key_value, method: :get, params: ['hello']
#
# puts "Finished - got: #{val.inspect}"
