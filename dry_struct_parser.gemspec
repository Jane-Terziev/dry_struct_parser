# frozen_string_literal: true

require_relative "lib/dry_struct_parser/version"

Gem::Specification.new do |spec|
  spec.name = "dry_struct_parser"
  spec.version = DryStructParser::VERSION
  spec.authors = ["Jane-Terziev"]
  spec.email = ["janeterziev@gmail.com"]

  spec.summary = "Generate a readable hash from a dry-struct schema"
  spec.description = "A parser which converts dry-struct schema into a readable hash for further
manipulation"
  spec.homepage = "https://github.com/Jane-Terziev/dry_struct_parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Jane-Terziev/dry_struct_parser"
  spec.metadata["source_code_uri"] = "https://github.com/Jane-Terziev/dry_struct_parser"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-struct", "~> 1"
end
