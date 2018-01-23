
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cryptocoins/version"

Gem::Specification.new do |spec|
  spec.name          = "cryptocoins"
  spec.version       = CryptoCoins::VERSION
  spec.authors       = ["teamdawi"]
  spec.email         = ["brett@teamdawi.com"]
  spec.licenses      = ['MIT']
  spec.summary       = %q{Crytocurrency Api using CoinMarketCaps Data and gathers News from sources}
  spec.description   = %q{Data and News Api for CryptoCurrencies}
  spec.homepage      = "https://github.com/bdawidowski/cryptocoins"
  spec.metadata    = { "source_code_uri" => "https://github.com/bdawidowski/cryptocoins" }
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "httparty", "~> 0.13.7"
  spec.add_development_dependency "nokogiri", "~> 1.8"
end
