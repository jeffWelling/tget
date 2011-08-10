require File.dirname(__FILE__) + "/spec_helper"
describe Tget::DList do
  include TgetSpecHelper

  before(:each) do
    @options= default_opts
  end
  
  it "Should initialize to contents of file" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    new_file(temp_file, "Fubar#{DLIST_SEP}gonzo\nFubar1#{DLIST_SEP}gonzo1\nFubar2#{DLIST_SEP}gonzo2\n")
    Tget::DList.new temp_file
    Tget::DList.has?('Fubar', 'gonzo').should == true
    Tget::DList.has?('fubar1', 'gonzo1').should == true
    Tget::DList.has?('fubar2', 'gonzo2').should == true
  end
  it "Should add shows" do
    Tget::DList.new ''
    Tget::DList.add "Fubar"+DLIST_SEP+"gonzo"
    Tget::DList.has?('Fubar', 'gonzo').should == true
  end
  it "Should err if invalid event is passed" do
    Tget::DList.new ''
    lambda { Tget::DList.add 0 }.should raise_error
  end
    
  it "Should write self to file when saved" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    Tget::DList.new ''
    Tget::DList.add "Fubar"+DLIST_SEP+"gonzo"
    Tget::DList.save temp_file
    File.exist?(temp_file).should == true
    contents=nil
    File.open(temp_file, 'r') {|file| contents= file.read }
    contents.class.should == String
    contents[/^.*\n/].should == "Fubar"+DLIST_SEP+"gonzo\n"
  end
end
