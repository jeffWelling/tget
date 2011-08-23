require File.dirname(__FILE__) + "/spec_helper"
describe Tget::Result do
  before(:each) do
    @options= Tget::Main.default_opts
  end
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end

  it "Should initialize, given appropriate input" do
    lambda {Tget::Result.new(nil,'I am a show', 's01e01')}.should raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', nil, 's01e01')}.should raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', nil)}.should raise_error
=begin
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', 's01e01')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', 'S01E01')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', 'S01e01')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', 'S00N')}.should raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1x02')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1x2')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1X2')}.should_not raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1X02')}.should_not raise_error
=end
  end
  it "Should be able to tell which show it is" do
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1x12').show.should == 'I am a show'
  end
  it "Should be able to tell which episode ID it is" do
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1x12').ep_id.should == '1x12'
  end
  it "Should have a download URL" do
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', '1x12').url.should == 'http://localhost/fubar.torrent'
  end
  it "Should convert to string cleanly" do
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', 's01e01').to_s}.should_not raise_error
  end

end
