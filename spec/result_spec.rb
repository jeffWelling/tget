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
  it "Should be able to hold >+1 alternate urls" do
    pre='http://localhost/'
    main_url=pre+'fubar1'
    alt_urls=[pre+'fubar2',pre+'fubar3',pre+'fubar4']
    result=Tget::Result.new(main_url, 'Some show', 's01e01')
    result.add_alt_urls alt_urls
    result.url.should == pre+'fubar1'
    result.alt_urls.should == [pre+'fubar2',pre+'fubar3',pre+'fubar4']
  end
end
