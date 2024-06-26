# coding: utf-8
# 
# This file is part of SitecoreScan
# https://github.com/bcoles/sitecore_scan
#

Gem::Specification.new do |s|
  s.name        = 'sitecore_scan'
  s.version     = '0.0.4'
  s.required_ruby_version = '>= 2.5.0'
  s.date        = '2024-05-29'
  s.summary     = 'Sitecore scanner'
  s.description = 'A simple remote scanner for Sitecore CMS'
  s.license     = 'MIT'
  s.authors     = ['Brendan Coles']
  s.email       = 'bcoles@gmail.com'
  s.files       = ['lib/sitecore_scan.rb']
  s.homepage    = 'https://github.com/bcoles/sitecore_scan'
  s.executables << 'sitecore-scan'

  s.add_dependency 'logger', '~> 1.6'
end
