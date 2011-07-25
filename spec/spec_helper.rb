require File.expand_path(File.dirname(__FILE__) + "/../lib/tget")
require 'fileutils'

module TgetSpecHelper
  def new_file(name, contents)
    File.open(name, 'w') do |f|
      f.puts contents
    end
  end
end
