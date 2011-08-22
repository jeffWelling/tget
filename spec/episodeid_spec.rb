require File.dirname(__FILE__) + "/spec_helper"
describe Tget::EpisodeID do
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end
  it "Should recognize format 'S04E04'"
  it "Should recognize format 's02e56'"
  it "Should recognize format '3x34'"
  it "Should recognize format 'National Geographic - Religion Is A Sham"
  it "Should not include crufty when parsing 'National Geographic - Religion Is A Sham [HDTV] MVGROUP'"
end
