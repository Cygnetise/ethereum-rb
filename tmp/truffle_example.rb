require 'oj'

path_out = File.expand_path "../../../", __FILE__
ENV["CONFIG_DIR"] = "#{path_out}/cygnetise_contracts/build"
ENV["CONTRACT_ADDRESS"] = "0x1ea0c8b5206579a0f15d6bc53d3e9ee53267a81b"
ENV["CONTRACT_NAME"] = "Cygnetise"
require_relative '../ethereum-rb'
ETH = EthereumRb::Eth.new
ETH.init


class Helper
  def to_hex(data)
    data.each_byte.map { |b| b.to_s(16) }.join
  end

  def to_bin(data)
    data.scan(/../).map { |x| x.hex.chr }.join
  end

  def clean(data)
    if data[0] == '0' && data[1] == 'x'
      data[2..-1]
    else
      data
    end
  end
end


class OrgUser
  # TODO: write automated tests in rspec
  def self.count()
    ETH.get contract: :cygnetise, method: :orgUsersCount, params: []
  end

  def self.get(id:)
    ETH.get contract: :cygnetise, method: :getOrgUserFull, params: [id]
  end

  def self.create(value:, org_id:, hash:, sig:, address:, user_address:)
    hash = Helper.clean hash
    sig = Helper.clean sig
    hash = Helper.to_bin hash
    sig = Helper.to_bin sig
    ETH.set contract: :cygnetise, method: :createOrgUser, params: [org_id, value, user_address, hash, sig, address]
  end

  def self.admins
    admins = []
    for i in 1..OrgUser.count
      orgUser = OrgUser.get id: i
      if orgUser['admin']
        admins.push orgUser
      end
    end
    return admins
  end

  def self.update()
    # Not yet implemented in smart contract
  end
end


class User < Helper

  attr_reader :id, :value, :hash, :sig, :address

  def initialize(value:, hash:, sig:, address:)
    @value = value
    @hash = hash
    @sig = sig
    @address = address

    create value: @value, hash: @hash, sig: @sig, address: @address
    @id = User.count
  end

  def create(value:, hash:, sig:, address:)
    # example args
    # value: hello
    # hash: 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
    # sig: 0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00
    # address: 0x11587d900c62749fdcd4434a1b7ae7651ccb3af3
    begin
      hash = clean hash
      sig = clean sig
      hash = to_bin hash
      sig = to_bin sig
      ETH.set contract: :cygnetise, method: :createUser, params: [value, hash, sig, address]
    rescue EthereumRbABI::ABI::EncodingError
      raise "ABI::EncodingError - Unable to encode values"
    end
  end

  def update(value:, hash:, sig:, address:)
    # value: hello vlad wulf
    # hash: 0xd618b8165defcb0775e8d059e93415a5ee57fab4cbb6177edba5991b9ada9c34
    # sig: 0x0010f5191cd66ed6338b78b987f61c03f7d24ed45f1ad6a01aa26c49e430ab805114d43214353f309bd806bbb327bdab94ee4c1200f9d5236b9ffb98a60ca6d001
    # address: 0x11587d900c62749fdcd4434a1b7ae7651ccb3af3
    begin
      hash = clean hash
      sig = clean sig
      hash = to_bin hash
      sig = to_bin sig
      ETH.set contract: :cygnetise, method: :updateUser, params: [@id, value, hash, sig, address]
    rescue EthereumRbABI::ABI::EncodingError
      raise "ABI::EncodingError - Unable to encode values"
    ensure
      @value = value
      @hash = hash
      @sig = sig
      @address = address
    end
  end

  # static
  def self.count
    begin
      ETH.get contract: :cygnetise, method: :usersCount, params: []
    rescue EthereumRbABI::ABI::DecodingError
      raise "ABI::DecodingError - Unable to decode value from ethereum"
    end
  end

  def self.get(id:)
    begin
      value = ETH.get contract: :cygnetise, method: :getUserFull, params: [id]
      value = nil if value.empty?
      begin
        value['_value'] = Oj.load value['_value']
      rescue
      end
      value
    rescue EthereumRbABI::ABI::DecodingError
      raise "ABI::DecodingError - Unable to decode value from ethereum"
    end
  end

  def self.getValue(id:)
    begin
      value = ETH.get contract: :cygnetise, method: :getUser, params: [id]
      value = nil if value.empty?
      begin
        value['_value'] = Oj.load value['_value']
      rescue
      end
      value
    rescue EthereumRbABI::ABI::DecodingError
      raise "ABI::DecodingError - Unable to decode value from ethereum"
    end
  end

  def is_admin?
    OrgUser.admins.each do |admin|
      if admin['_user_id'] == @id
        return true
      end
    end
    return false
  end

  def is_adminOf?(org:)
    OrgUser.admins.each do |admin|
      if admin['_user_id'] == @id && admin['_org_id'] == org.id
        return true
      end
    end
    return false
  end
end

# user = User.new value: 'hello', hash: '0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8', sig: '0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00', address: '0x11587d900c62749fdcd4434a1b7ae7651ccb3af3'
# puts user.id
# puts user.value
# puts user.hash
# puts user.sig
# puts user.address




# value: hello
    # hash: 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
    # sig: 0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00
    # address: 0x11587d900c62749fdcd4434a1b7ae7651ccb3af3
# user = User.create value: 'hello', hash: '0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8', sig: '0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00', address: '0x11587d900c62749fdcd4434a1b7ae7651ccb3af3'
# puts user


class Org
  # TODO: write automated tests in rspec
  def self.count()
    ETH.get contract: :cygnetise, method: :orgsCount, params: []
  end

  def self.get(id:)
    ETH.get contract: :cygnetise, method: :getOrgFull, params: [id]
  end

  def self.getValue(id:)
    # TODO: add multi return support
    ETH.get contract: :cygnetise, method: :getOrg, params: [id]
  end

  def self.create(value:, user_id:, hash:, sig:, address:)
    hash = Helper.clean hash
    sig = Helper.clean sig
    hash = Helper.to_bin hash
    sig = Helper.to_bin sig
    ETH.set contract: :cygnetise, method: :createOrg, params: [value, user_id, hash, sig, address]
  end

  def self.update(id:, value:, hash:, sig:, address:)
    hash = Helper.clean hash
    sig = Helper.clean sig
    hash = Helper.to_bin hash
    sig = Helper.to_bin sig
    ETH.set contract: :cygnetise, method: :updateOrg, params: [id, value, hash, sig, address]
  end
end


class Org
  # TODO: write automated tests in rspec
  def self.count()
    ETH.get contract: :cygnetise, method: :orgsCount, params: []
  end

  def self.get(id:)
    begin
      value = ETH.get contract: :cygnetise, method: :getOrgFull, params: [id]
      value = nil if value.empty?
      value['_value'] = Oj.load value['_value']
      value
    rescue EthereumRbABI::ABI::DecodingError
      raise "ABI::DecodingError - Unable to decode value from ethereum"
    end
  end

  def self.getValue(id:)
    # TODO: add multi return support
    ETH.get contract: :cygnetise, method: :getOrg, params: [id]
  end

  def self.all
    list = []
    for i in 1..self.count
      list.push(self.get id: i)
    end
    list
  end

  def self.create(value:, user_id:, hash:, sig:, address:)
    hash = Helper.clean hash
    sig = Helper.clean sig
    hash = Helper.to_bin hash
    sig = Helper.to_bin sig
    ETH.set contract: :cygnetise, method: :createOrg, params: [value, user_id, hash, sig, address]
  end

  def self.update(id:, value:, hash:, sig:, address:)
    hash = Helper.clean hash
    sig = Helper.clean sig
    hash = Helper.to_bin hash
    sig = Helper.to_bin sig
    ETH.set contract: :cygnetise, method: :updateOrg, params: [id, value, hash, sig, address]
  end
end




class Signatory
  # TODO: write automated tests in rspec
  def self.count()
    ETH.get contract: :cygnetise, method: :entriesCount, params: []
  end

  def self.get(id:)
    ETH.get contract: :cygnetise, method: :getEntryFull, params: [id]
  end

  def self.getValue(id:)
    # TODO: add multi return support
    ETH.get contract: :cygnetise, method: :getEntry, params: [id]
  end

  def self.create()
    # Not yet implemented in smart contract
  end

  def self.update()
    # Not yet implemented in smart contract
  end
end

# value: hello
    # hash: 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
    # sig: 0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00
    # address: 0x11587d900c62749fdcd4434a1b7ae7651ccb3af3
# user = User.create value: 'hello', hash: '0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8', sig: '0xde4fff3c6895f6f6e6342e327a9c09aa41fc9acd176a73f931b0b25f04e2b72261e99714f624547eaac24a3235cd7a8f051991c156cc03420eb4810544d1ffda00', address: '0x11587d900c62749fdcd4434a1b7ae7651ccb3af3'
# puts user



# user = Org.all
# puts user
