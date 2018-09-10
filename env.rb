require 'socket'
require 'net/http'
require 'json'

require 'bundler'
Bundler.require :default

require 'oj'

# Oj.default_options = { mode: :compat }

path = File.expand_path "../", __FILE__
ETH_PATH = path

# ---------
# configs:

ETH_LOG = false
# ETH_LOG = true # enable logs for debugging purposes (development)

DEBUG_CONN = false
# DEBUG_CONN = true

IPC_PATH = "#{ENV["HOME"]}/.parity/jsonrpc.ipc"

# RPC_HOST = "http://127.0.0.1"
RPC_HOST = ENV["ETH_APP_HOST"] || "localhost"
RPC_PORT = ENV["ETH_APP_PORT"] || "8545"

CONF_NILS = true # returns nil instead of blank string if the value is not set

CONFIG_DIR = if defined? ETH_CONFIG_DIR
  ETH_CONFIG_DIR
elsif ENV["CONFIG_DIR"] && !ENV["CONFIG_DIR"].empty?
  ENV["CONFIG_DIR"]
else
  raise "Error - config dir was not set - please set 'ETH_CONFIG_DIR' in production" if ENV["RACK_ENV"] == "production"
  "#{path}/config"
end

# initialize vendored Ethereum::ABI
#
require_relative "lib/vendor/keccak"
require_relative "vendor/ethereum-rb-abi/constant"
require_relative "vendor/ethereum-rb-abi/utils"
require_relative "vendor/ethereum-rb-abi/exceptions"
require_relative "vendor/ethereum-rb-abi/abi"
include EthereumRbABI::ABI
include EthereumRbABI::Utils


# init main module
module EthereumRb
end

require_relative './lib/vendor/formatter'
FRM = EthereumRb::Formatter.new




# ---

require_relative 'lib/version'
require_relative 'lib/utils'
require_relative 'lib/types'
require_relative 'lib/formatting'
require_relative 'lib/rpc_calls'
require_relative 'lib/tx_handlers'
require_relative 'lib/actions_main'
require_relative 'lib/response_parsing'
require_relative 'lib/method_lookup' # find the implemented RPC methods here

require_relative 'lib/connection'
require_relative 'lib/interface'

# ---

module EthereumRb
  class Eth
    include Types
    include Interface
    include TxHandlers
    include ResponseParsing
    include Formatting
    include RpcCalls
    include ActionsMain
    include Utils
  end
end
