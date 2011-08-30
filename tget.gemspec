lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'tget/version'

Gem::Specification.new do |spec|
  spec.name=      'tget'
  spec.version=   Tget::VERSION
  spec.platform=  Gem::Platform::RUBY
  spec.authors=   'Jeff Welling'
  spec.email=     'jeff.welling+tget@gmail.com'
  spec.homepage=  'https://github.com/jeffWelling/tget'
  spec.summary=   'Search for and download .torrent files for tv shows as they are released'
  spec.description="Tget searches torrent aggregator sites for tv shows that you specify in the config file, and downloads those files to a directory. To automate, run from cron at a schedule of your choosing."

  spec.rubyforge_project= 'tget'
  spec.add_development_dependency='rspec'
  spec.files= Dir.glob("{bin,lib}/**/*")+ %w(LICENSE README.markdown)
  spec.executables= ['tget']
  spec.require_path='lib'
end 
