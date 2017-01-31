lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vscal/version"

Gem::Specification.new do |s|
  s.name        = "vscal"
  s.version     = VsCal::VERSION
  s.date        = "2017-01-31"
  s.summary     = "A command line calendar printer"
  s.description = <<-EOF
                  A cal/ncal replacement with support for ANSI terminal colors,
                  month ranges and multiple formats for defining month ranges.
                  EOF
  s.authors     = ["Ville Siltanen"]
  s.email       = "ville.siltanen@iki.fi"
  s.homepage    = "https://github.com/villez/vscal"
  s.files       = Dir.glob("lib/**/*.rb")
  s.executables << "vscal"
  s.require_paths = ["lib"]
  s.license     = "MIT"

  s.add_development_dependency "bundler", "~> 1.13"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.10"
end
