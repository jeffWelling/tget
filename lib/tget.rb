# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

#parse options

require 'tget/main'
module Tget
  autoload :VERSION, 'tget/version'

  def self.open()
    Main.run
  end
end
