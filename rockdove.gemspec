# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rockdove/version"

Gem::Specification.new do |s|
  s.name        = "rockdove"
  s.version     = Rockdove::VERSION
  s.authors     = ["Kiran Soumya"]
  s.email       = ["kiran.soumya@gmail.com"]
  s.homepage    = "https://github.com/kiranh/rockdove"
  s.summary     = %q{Incoming mail processing daemon for Exchange Web Services (EWS)}
  s.description = %q{Incoming mail processing daemon for Exchange Web Services (EWS). This is the Ruby Gem that does fetching, parsing and watching the mailbox for further processing.}

  s.rubyforge_project = "rockdove"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rspec-mocks"
  s.add_development_dependency "simplecov"
  
  s.add_runtime_dependency "raad" 
  s.add_runtime_dependency "viewpoint"
  s.add_runtime_dependency "email_reply_parser"
  s.add_runtime_dependency "logger" 
end
