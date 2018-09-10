# from DigixGlobal/ethereum-ruby on github: https://github.com/DigixGlobal/ethereum-ruby/blob/2c9b79c3e9f9e1f8f9569fb26162888a081c0e38/lib/ethereum/formatter.rb

module EthereumRb
  class Formatter

    # we're using only to/from ascii, everything else is commented

    def to_ascii(hexstring)
      return nil if hexstring.nil?
      hexstring.gsub(/^0x/,'').scan(/.{2}/).collect {|x| x.hex}.pack("c*")
    end

    def from_ascii(ascii_string)
      return nil if ascii_string.nil?
      ascii_string.unpack('H*')[0]
    end

    def to_int(hexstring)
      return nil if hexstring.nil?
      (hexstring.gsub(/^0x/,'')[0..1] == "ff") ? (hexstring.hex - (2 ** 256)) : hexstring.hex
    end

  end

end
