require "./lib/vscal/version"

Gem::Specification.new do |s|
  s.name        = "vscal"
  s.version     = VsCal::VERSION
  s.date        = "2017-01-19"
  s.summary     = "A command line calendar printer"
  s.description = <<-EOF
                  A cal/ncal replacement with support for ANSI terminal colors,
                  month ranges and multiple formats for defining month ranges.
                  EOF
  s.authors     = ["Ville Siltanen"]
  s.email       = "ville.siltanen@iki.fi"
  s.files       = Dir.glob("lib/**/*.rb")
  s.executables << "vscal"
  s.license     = "MIT"
end
