Gem::Specification.new do |s|
  s.name        = "vscal"
  s.version     = "0.0.1"
  s.date        = "2017-01-19"
  s.summary     = "A command line calendar printer"
  s.description = <<-EOF
                  A cal/ncal replacement with support for ANSI terminal colors,
                  month ranges and multiple formats for defining month ranges.
                  EOF
  s.authors     = ["Ville Siltanen"]
  s.email       = "ville.siltanen@iki.fi"
  s.files       = ["lib/vscal.rb"]
  s.executables << "vscal"
  s.license     = "MIT"
end
