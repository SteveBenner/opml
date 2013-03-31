# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opml/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name    = 'opml'
  s.version = Opml::VERSION

  s.authors  = ["Melih Onvural", "Joshua Peek"]
  s.date     = Date.today
  s.email    = ''
  s.homepage = 'https://github.com/amplifize/opml'

  s.summary     = 'Library to read OPML files.'
  s.description = 'Library to read OPML files.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  
  s.platform = Gem::Platform::RUBY
end
