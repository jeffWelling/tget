require File.dirname(__FILE__) + "/spec_helper"
describe Tget::EpisodeID do
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end
  it "Should recognize format 'S04E04'" do
    Tget::EpisodeID.new('S04E04').id.should == 's04e04'
  end
  it "Should recognize format 's02e56'" do
    Tget::EpisodeID.new('s02e56').id.should == 's02e56'
  end
  it "Should recognize format '3x34'" do
    lambda {Tget::EpisodeID.new('3x34')}.should_not raise_error(Tget::EpisodeID::ShowReqd)
    Tget::EpisodeID.new('3x34').id.should == 's3e34'
  end
  it "Should recognize format 'National Geographic - Religion Is A Sham" do
    epid=Tget::EpisodeID.new('National Geographic - Religion Is A Sham', 'National Geographic')
    epid.id.should == nil
    epid.name.should == 'Religion Is A Sham'
  end
  it "Should recognize format 'National Geographic - Religion Is A Sham - " do
    epid=Tget::EpisodeID.new('National Geographic - Religion Is A Sham', 'National Geographic')
    epid.id.should == nil
    epid.name.should == 'Religion Is A Sham'
  end
  it "Should not include crufty when parsing 'National Geographic - Religion Is A Sham [HDTV] MVGROUP'" do
    epid=Tget::EpisodeID.new('National Geographic - Religion Is A Sham [HDTV] MVGROUP', 'National Geographic')
    epid.id.should == nil
    epid.name.should == 'Religion Is A Sham'
  end
  it "Should not explode when the airdate uses periods" do
    lambda {Tget::EpisodeID.new('David.Letterman.2011.08.22.Denis.Leary.HDTV.XviD-2HD.torrent', 'Fubar')}.should_not raise_error
  end
end
