module EthereumRb::Types

  private

  def to_ascii(value)
    EthereumRb::Formatter.new.to_ascii value
  end

  def from_ascii(value)
    EthereumRb::Formatter.new.from_ascii value
  end
  
end
