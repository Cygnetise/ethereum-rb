require_relative 'spec_helper'
require_relative '../ethereum'

ETH = EthereumRb::Eth.new
ETH.start!

describe "RPC Calls" do
  it "gets block height" do
    ETH.block_get.should_not be_nil
    ETH.block_get.should be_a Integer
    ETH.block_get.should be >= 0
  end

  it "coinbase" do
    coinbase = ETH.coinbase
    coinbase[0..1].should == "0x"
    coinbase.size.should  == 42
  end

  it "gets balance" do
    scale = 10 ** 5
    balance = ETH.balance
    balance[0..1].should == "0x"
    # TODO: FIXME: return a numeric balance
  end

  specify "get (eth_call)" do
    response = ETH.set contract: :key_value, method: :set, params: ["foo", ""]
    response.should be true

    # note: this spec requires deployed contracts
    value = ETH.get contract: :key_value, method: :get, params: ["foo"]
    value.should eq nil
  end

  specify "set (eth_sendTransaction)" do
    response = ETH.set contract: :key_value, method: :set, params: ["foo", "bar"]
    response.should be true

    # TODO:
    # expect {
    #   ETH.set contract: :key_value, method: :set, params: ["foo", "bar", "asd"]
    # }.to raise_error(RuntimeError)

    value = ETH.get contract: :key_value, method: :get, params: ["foo"]
    value.should eq "bar"
  end

end
