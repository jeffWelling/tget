require File.dirname(__FILE__) + "/spec_helper"
describe Tget::DList do
  include TgetSpecHelper

  before(:each) do
    @options= default_opts
  end
  
  it "Should initialize to contents of file" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    new_file(temp_file, "Fubar\nFubar1\nFubar2\n")
    Dlist.new temp_file
    
  end
  it "Should add shows"
  it "Should err if invalid event is passed"
  it "Should write self to file when saved"

end
