require_relative '../ethereum-rb'

ETH = EthereumRb::Eth.new

module EthereumRb::CRU
  def attributes(attrs)
    @@attrs = attrs
  end

  def get(id)
    ETH.get contract: :entries, method: :get, params: [id]
  end

  def create(attrs)
    ETH.set contract: :entries, method: :create, params: attrs.values
  end

  def update(attrs)
    ETH.set contract: :entries, method: :update, params: attrs.values
  end

  def count
    ETH.get contract: :entries, method: :entriesCount, params: []
    # ETH.get contract: :entries, method: :getEntriesCount, params: []
  end
end

class Entry
  extend EthereumRb::CRU
  attributes %w(name)
end

ETH.start!

count = Entry.count
puts "entries count: #{count.inspect}\n\n"

# Entry.create name: "asd"

entry = Entry.get 1
puts "entry: #{entry}\n\n"

Entry.update "_id" => 1, name: "asdasd"


# val = ETH.get contract: :op_return, method: :data, params: []
# # puts "Finished - got: #{val}"
