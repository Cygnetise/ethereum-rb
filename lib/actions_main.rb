
module ActionsMain
  # Get function (not an http method, not a GET request, it just reads data from ethereum - reads via RPC from contract data storage)
  #
  #
  def get(contract:, method:, params: [])
    # setting up (config)
    #
    from = @coinbase
    contract = @interface.fetch contract
    contract_address = contract[:address]

    # setting up
    #
    method_name = method


    method = contract[:methods].find{ |m| m[:name] == method_name.to_s }
    raise "Cannot call contract method '#{method_name}' (contract: #{contract[:class_name]})" unless method
    method = sym_keys method
    sig = method[:methodId]
    raise "Cannot find sha3 signature for method '#{method}'" unless sig

    # processing data - data transformation
    #
    puts "GET - transforming inputs" if ETH_LOG
    params = transform_params params, inputs: method[:inputs]
    data = "#{sig}#{params}"
    puts "data: #{data}" if ETH_LOG
    # raise contract.inspect
    outputs = method[:outputs]

    puts "get #{contract[:class_name]}.#{method_name}(#{params})"  if ETH_LOG
    # this is the main call
    resp = read [{from: from, to: contract_address, data: data}]
    puts "Resp (raw): #{resp}" if ETH_LOG

    # resp = parse_types resp, outputs: outputs
    # puts "Resp (types): #{resp}" if ETH_LOG

    # resp = FRM.from_payload(resp)
    # resp = [resp] unless resp.is_a? Array
    puts "GET - transforming outputs" if ETH_LOG
    puts "outputs: #{method[:outputs].inspect}" if ETH_LOG # 2
    puts "resp: #{resp.inspect}" if ETH_LOG # 2
    resp = transform_outputs resp, outputs: method[:outputs]

    resp = if resp.size == 1
      resp.first
    else
      # TODO: extract in formatter
      # render_outputs
      resp_hash = {}
      method[:outputs].each_with_index do |out, idx|
        resp_hash[out["name"]] = resp[idx]
      end
      resp_hash
    end
    puts "Resp: #{resp.inspect}" if ETH_LOG
    return if CONF_NILS && !resp.nil? && resp.is_a?(String) && resp.empty?

    resp
  end


  # Set method # ------------------------------------------------#
  #
  # write method, transact method - it sets data into contract storage (OP_RETURN functionality) or executes any function that doeas that.
  #
  #
  #         storage
  #    #-----------------#
  #    #                 #
  #    #                 #    <-------- method call ()
  #    #                 #
  #    #-----------------#
  #
  #
  #         storage
  #    #-----------------#
  #    #                 #
  #    #      bla        #    <-------- set("bla")
  #    #                 #
  #    #-----------------#
  #
  #

# This is called OP_RETURN

# like in bitcoin, the one that

# ----------------------------------------


  #
  #         storage
  #    #-----------------#
  #    #                 #
  #    #      bla        #    <-------- set("bla")
  #    #                 #
  #    #-----------------#
  #
  #
  #
  #
  #    note:
  #
  #    this operation on a public blockchain requires a fee (some fraction of millibit in bitcoin
  #    or maybe a millibit or two in the future
  #
  #    if you want something prioritized or if the bitcoin fees have raised a bit
  #    and an amount of gas (pseudo-ether - cost based on value of th)"
  #
  #
  #
  #
  def set(contract:, method:, params: [])
    last_block = block_get
    transact contract: contract, method: method, params: params
    if wait_block last_block
      true
    else
      puts "retrying set..."
      set contract: contract, method: method, params: params
    end
  end


  private

  def transact(contract:, method:, params: [])
    from = @coinbase
    raise "Ethereum-Rb RPC is not initialized, please run ETH.start! or RPC.start! to have a non-nil coinbase" unless from
    contract = @interface.fetch contract
    contract_address = contract[:address]

    method_name = method
    method = contract[:methods].find{ |m| m[:name] == method_name.to_s }
    raise "Cannot call contract method '#{method_name}' (contract: #{contract[:class_name]})" unless method
    method = sym_keys method
    sig = method[:methodId]
    raise "Cannot find sha3 signature for method '#{method}'" unless sig

    params_raw = params
    puts "SET - transforming params" if ETH_LOG # 2
    params = transform_params params, inputs: method[:inputs], set: true
    data = "#{sig}#{params}"

    puts "set data: #{data}" if ETH_LOG # 2

    gas = ENV["ETH_GAS"] || "0x2FAF080"
    # gas = "0x4fefd8" # 32488100 - limit 32488160 - gaslimit in chain.json is 1C9C380 (30000000) - 1EFBA00

    puts "set #{contract[:class_name]}.#{method_name}(#{params_raw})" if ETH_LOG
    resp = write [{from: from, to: contract_address, data: data, gas: gas}]

    resp
  end

  def block_get
    res = block
    "#{res}".hex
  end

end
