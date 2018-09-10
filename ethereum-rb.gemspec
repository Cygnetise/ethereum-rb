path = File.expand_path "../", __FILE__
require "#{path}/lib/version"


Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ethereum-rb'
  s.version     = EthereumRb::VERSION
  s.summary     = 'Call Ethereum via Ruby'
  s.description = 'Ethereum RPC Ruby API'

  s.author   = "Francesco 'makevoid' Canessa"
  s.email    = 'makevoid@gmail.com'
  s.homepage = 'http://github.com/makevoid'

  s.files        = Dir['Readme.md', "Gemfile", "Gemfile.lock", "*.rb", 'lib/**/*', 'config/**/*', 'node/**/*', 'contracts/**/*']
  s.require_path = '.'

  s.add_runtime_dependency 'digest-sha3'#, '~> 1.1.0'
  s.add_runtime_dependency 'typhoeus'
  s.add_runtime_dependency 'oj',          "~> 3.2"
end
