# frozen_string_literal: true

require_relative "lib/foggy-mirror/version"

Gem::Specification.new do |spec|
  spec.name          = "foggy-mirror"
  spec.version       = FoggyMirror::VERSION
  spec.authors       = ["Pedro Carbajal"]
  spec.email         = ["pedro_c@beezwax.net"]

  spec.summary       = "Tool to create math-based tiny blurry versions of raster images"
  spec.description   = "foggy-mirror takes a raster image and outputs a blurred version of it using SVG or CSS"
  spec.homepage      = "https://github.com/beezwax/foggy-mirror"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|img)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "ruby-vips", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "pry-byebug"
end
