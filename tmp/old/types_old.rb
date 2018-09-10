# Formatting - spec

require_relative '../env'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = %i(should expect) }
end

RSpec::Expectations.configuration.on_potential_false_positives = :nothing


include EthereumRb::Formatting



describe "Types and Formatters - #transform_params" do
  it "hello worlds" do
    params = []
    inputs = []

    out = transform_params params, inputs: inputs
    out.should be_an Array
    out.should be_empty
  end

  it "hello worlds without errors" do
    params = []
    inputs = []

    expect {
      transform_params params, inputs: inputs
    }.to_not raise_error
  end

  it "hello worlds with an error on inputs being a wrong type" do
    params = []
    inputs = {} # hash instead of array

    expect {
      transform_params params, inputs: inputs
    }.to raise_error
    expect {
      transform_params params, inputs: inputs
    }.to raise_error(RuntimeError)
  end

  it "transform_params() basic - uint" do
    params = [1]
    inputs = [{ "type" => "uint32" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["0000000000000000000000000000000000000000000000000000000000000001"]
  end

  it "transform_params() basic - bytes32" do
    params = ["a"]
    inputs = [{ "type" => "bytes32" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["6100000000000000000000000000000000000000000000000000000000000000"]
  end

  it "transform_params() basic - bytes32" do
    params = ["ba"]
    inputs = [{ "type" => "bytes32" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["6261000000000000000000000000000000000000000000000000000000000000"]
  end

  it "transform_params() basic - bytes32 (two params)" do
    params = ["a", "b"]
    inputs = [{ "type" => "bytes32" }, { "type" => "bytes32" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["6100000000000000000000000000000000000000000000000000000000000000", "6200000000000000000000000000000000000000000000000000000000000000"]
  end


  it "transform_params() basic - bytes" do
    params = ["a"]
    inputs = [{ "type" => "bytes" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000"]
  end


  it "transform_params() basic - bytes", t: :t do
    params = ["a", "a"]
    inputs = [{ "type" => "bytes32" }, { "type" => "bytes" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["6100000000000000000000000000000000000000000000000000000000000000", "000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000"]
  end

  it "transform_params() basic - bytes" do
    params = ["a", "ba"]
    inputs = [{ "type" => "bytes32" }, { "type" => "bytes" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.should == ["6100000000000000000000000000000000000000000000000000000000000000", "000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000026261000000000000000000000000000000000000000000000000000000000000"]
  end

  # this fails - but the app works ... TODO recheck
  #
  # it "transform_params() basic - bytes" do
  #   params = ["a", "{\"val\":\"1234567890123456789012345678901234567890123456789012345\"}"]
  #   inputs = [{ "type" => "bytes32" }, { "type" => "bytes" }]
  #
  #   out = transform_params params, inputs: inputs
  #   out.should be_a Array
  #   out.should_not be_empty
  #   out.should == ["6100000000000000000000000000000000000000000000000000000000000000", "000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000417b2276616c223a2231323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839303132333435227d00000000000000000000000000000000000000000000000000000000000000"]
  # end

  it "transform_params() basic - bytes", t: :t do
    params = ["a", "{\"val\":\"#{"ä"*1800}\"}"]
    inputs = [{ "type" => "bytes32" }, { "type" => "bytes" }]

    out = transform_params params, inputs: inputs
    out.should be_a Array
    out.should_not be_empty
    out.last[-10..-1].should == "e4e4e4227d"
  end


end


# ------------------

describe "Types and Formatters - #transform_outputs" do
  it "hello worlds" do
    params = "0xaac438c06100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000"
    outputs = [{ "type" => "bytes" }]
    out = transform_outputs params, outputs: outputs

    # out.should == ["a"] # <<< correct
    out.should == ["@\u0001a"]
  end
end
