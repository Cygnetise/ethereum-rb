module Ethereum
module Formatting

  private

  # transform input params (set)
  #
  def transform_params(params, inputs:, set: false)
    raise "\n\nError: inputs should be or behave like an array - inputs.class: #{inputs.class}\n\n" unless inputs.is_a? Array

    input_types = inputs.map{ |inp| inp["type"] }

    value = encode input_types, params

    value = FRM.from_ascii value

    puts "transform_params - transformed: #{value.inspect}" if ETH_LOG

    value
    # return [] if value.empty?
    #
    # [value]
  end

  # transform output params (set)
  #
  def transform_outputs(params, outputs:)
    raise "\n\nError: outputs should be or behave like an array - outputs.class: #{outputs.class}\n\n" unless outputs.is_a? Array

    params.gsub! /^0x/, ''

    output_types = outputs.map{ |out| out["type"] }

    params = FRM.to_ascii params

    values = decode output_types, params


    puts "transform_outputs - transformed outputs:\n #{values.inspect}\n\n" if ETH_LOG # 2
    values
  end

  # parse output types
  #
  # def parse_types(resp, outputs:)
  #   if resp.is_a? Array
  #     values = resp
  #     values.map.with_index do |value, idx|
  #       output = outputs[idx]
  #       parse_type_read value, type: output["type"]
  #     end
  #   else
  #     output = outputs.first
  #     parse_type_read resp, type: output["type"]
  #   end
  # end

end
end
