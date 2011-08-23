require File.dirname(__FILE__) + "/spec_helper"
describe Tget::Result do
  before(:each) do
    @options= Tget::Main.default_opts
  end
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end

  it "Should initialize, given appropriate input" do
    lambda {Tget::Result.new(nil,'I am a show', Tget::EpisodeID.new('s01e01'))}.should raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', nil, Tget::EpisodeID.new('s01e01'))}.should raise_error
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', nil)}.should raise_error
  end
  it "Should be able to tell which show it is" do
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', Tget::EpisodeID.new('1x12')).show.should == 'I am a show'
  end
  it "Should be able to tell which episode ID it is" do
    e=Tget::EpisodeID.new('1x12')
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show',e ).ep_id.should == e
  end
  it "Should have a download URL" do
    Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', Tget::EpisodeID.new('1x12')).url.should == 'http://localhost/fubar.torrent'
  end
  it "Should convert to string cleanly" do
    lambda {Tget::Result.new('http://localhost/fubar.torrent', 'I am a show', Tget::EpisodeID.new('s01e01')).to_s}.should_not raise_error
  end

end
