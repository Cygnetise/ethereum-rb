path_out = File.expand_path "../../../", __FILE__
ENV["CONFIG_DIR"] = "#{path_out}/cygnetise_contracts/build"
ENV["CONTRACT_ADDRESS"] = "0x1ea0c8b5206579a0f15d6bc53d3e9ee53267a81b"
ENV["CONTRACT_NAME"] = "Cygnetise"
require_relative '../ethereum'
ETH = Ethereum::Eth.new
ETH.init
# ETH....

# ETH.get contract: :cygnetise, method: :getter_aka_call, params: [id]
#
# ETH.set contract: :cygnetise, method: :setter_aka_sendtransaction, params: attrs.values

class User
  def self.count()
    ETH.get contract: :cygnetise, method: :usersCount, params: []
  end

  def self.get(id:)
    ETH.get contract: :cygnetise, method: :getUser, params: [id]
  end

  def self.create(value:, hash:, sig:, address:)
    # example args
    # value: hello
    # hash: 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
    # sig: 0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00
    # address: 0x11587d900c62749fdcd4434a1b7ae7651ccb3af3
    ETH.set contract: :cygnetise, method: :fakeCreate, params: [value, hash, sig, address]
  end

  def self.getVar()
    ETH.get contract: :cygnetise, method: :getVar, params: []
  end

  def self.getVar2()
    ETH.get contract: :cygnetise, method: :getVar2, params: []
  end

  def self.getVar3()
    ETH.get contract: :cygnetise, method: :getVar3, params: []
  end

  def self.setVar(data:)
    ETH.set contract: :cygnetise, method: :setVar, params: [data]
  end

  def self.setVar2(data:)
    ETH.set contract: :cygnetise, method: :setVar2, params: [data]
  end

  def self.setVar3(data:)
    ETH.set contract: :cygnetise, method: :setVar3, params: [data]
  end

end

# count = User.count
# puts "USER count: #{count}"

# user = User.get id: 1
# puts "USER #1: #{user}"

# set_test = User.setTest2 data: '0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8'
# puts "response from set test #{set_test}"

# getVar = User.getVar
# puts "response from get test: #{getVar}"

# setVar2 = User.setVar2 data: '0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8'
# puts "response from set var 2 #{setVar2}"


def bin_to_hex(s)
  s.each_byte.map { |b| b.to_s(16) }.join
end

# getVar2 = User.getVar2
# puts 'response should be 1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8'
# puts "response got: #{bin_to_hex(getVar2)}"


#for 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
# data = "de4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00".scan(/../).map { |x| x.hex.chr }.join
# setVar2 = User.setVar2 data: data
# puts "size: #{data.size}"
# puts "response from set var 2 #{setVar2}"



# data = "de4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00".scan(/../).map { |x| x.hex.chr }.join
data = 'ff'
puts "size: #{data.size}"
setVar3 = User.setVar3 data: data
puts "response from set var 3 #{setVar3}"

# getVar3 = User.getVar3
# puts 'response should be ff'
# puts "response got: #{getVar3}"



