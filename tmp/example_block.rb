require_relative '../ethereum-rb'

ETH = EthereumRb::Eth.new

ETH.start do |eth|
  val = eth.get contract: :op_return, method: :data, params: []
  puts "Finished - got: #{val}"
end
