require_relative '../../ethereum-rb'
require 'pp'

RPC = EthereumRb::Eth.new

RPC.start!

methods = RPC.methods - Object.methods - [:start, :init, :start!, :load_interface, :parse_interface]

puts "RPC loaded, type RPC.block_get or any or the following methods to get started:\nRPC.#{methods.sort.join ", RPC."}\nRefer to the doc to make transactions etc... enjoy!\n\n"
