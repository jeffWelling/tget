require File.dirname(__FILE__) + "/spec_helper"
describe Tget::Result do
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end

  it "Should initialize, given appropriate input"
  it "Should be able to tell which show it is"
  it "Should be able to tell which episode ID it is"
  it "Should have a download URL"
  it "Should convert to string cleanly"

end
