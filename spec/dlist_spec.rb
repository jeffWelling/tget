#    This file is part of tget.
#    Copyright 2011 Jeff Welling
#
#    tget is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    tget is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with tget.  If not, see <http://www.gnu.org/licenses/>.
#
require File.dirname(__FILE__) + "/spec_helper"
describe Tget::DList do
  include TgetSpecHelper

  before(:each) do
    @options= Tget::Main.default_opts
    extend Debug
    these_be_options @options
  end
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end
  
  it "Should initialize to contents of file" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    new_file(temp_file, "Fubar#{DLIST_SEP}gonzo\nFubar1#{DLIST_SEP}gonzo1\nFubar2#{DLIST_SEP}gonzo2\n")
    Tget::DList.load temp_file
    Tget::DList.has?('Fubar', 'gonzo').should == true
    Tget::DList.has?('fubar1', 'gonzo1').should == true
    Tget::DList.has?('fubar2', 'gonzo2').should == true
  end
  it "Should add shows" do
    Tget::DList.add "Fubar"+DLIST_SEP+"gonzo"
    Tget::DList.has?('Fubar', 'gonzo').should == true
  end
  it "Should err if invalid event is passed" do
    lambda { Tget::DList.add 0 }.should raise_error
  end
    
  it "Should write self to file when saved" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    Tget::DList.add "Fubar"+DLIST_SEP+"gonzo"
    Tget::DList.save temp_file
    File.exist?(temp_file).should == true
    contents=nil
    File.open(temp_file, 'r') {|file| contents= file.read }
    contents.class.should == String
    contents[/^.*\n/].should == "Fubar"+DLIST_SEP+"gonzo\n"
  end
  it "Should never grow larger than MAX_DF|#{Tget::DList.max_df}"
  it "Should not allow duplicates"
end
