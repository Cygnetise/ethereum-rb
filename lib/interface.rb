# require 'pp'

module EthereumRb
  module Interface
    # ABI

    include Utils

    def load_interface(interface_name = "contract_interface.json")
      interface = "#{CONFIG_DIR}/contracts/#{interface_name}"
      interface = File.read interface
      interface = JSON.parse interface
      parse_interface interface
    end

    # this parse has been ported from bapp_parity (from coffeescript to ruby): https://github.com/appliedblockchain/bapp_parity/blob/60f1e69efdb6bc599d60c81ce0bf66b59431bd9e/contract_deploy/src/contracts_lib.coffee#L122-L156

    def keccak(string)
      Keccak.hexdigest string, 1088, 512, 256
    end

    def parse_interface(interface)
      interface = sym_keys interface
      # ----------

      # get this via `truffle test` looking at any `Contract created:` log lines in `ethereumjs-testrpc` (docker logs contaioner_id | grep created )
      config_address = ENV["CONTRACT_ADDRESS"]

      contract_class = ENV["CONTRACT_NAME"]
      abi = interface.fetch :abi
      methods = []
      getters = []
      setters = []

      abi_methods = abi.select{ |token| token.fetch("type") == "function" }
      abi_methods.map do |abi_method|
        inputs = abi_method.fetch "inputs"
        is_setter = !inputs.empty? && !abi_method.fetch("constant")

        type = is_setter ? "setter" : "getter"
        input_types = inputs.map{ |input| input.fetch "type" }
        method_id = keccak("#{abi_method.fetch("name")}(#{input_types.join ','})")
        method_id = "0x#{method_id[0..7]}"

        method = {
          name:     abi_method.fetch("name"),
          kind:     type,
          inputs:   abi_method.fetch("inputs"),
          outputs:  abi_method.fetch("outputs"),
          methodId: method_id,
        }

        methods << method
        # if method.fetch("kind") == "getter"
        if method["kind"] == "getter"
          getters << method
        else
          setters << method
        end

        log = false
        if log
          require 'pp'
          puts "\nGETTERS"
          pp getters
          puts "\n\nSETTERS\n\n"
          pp setters
        end

        interface.merge!(
          address:    config_address,
          class_name: contract_class,
          methods:    methods.map{ |m| sym_keys m },
          getters:    getters.map{ |m| sym_keys m },
          setters:    setters.map{ |m| sym_keys m },
        )
      end

      {
        contract_class.downcase.to_sym => interface
      }
    end
  end

  ABI = Interface
end
