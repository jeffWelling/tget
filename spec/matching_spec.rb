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

describe Tget::Main do
  include TgetSpecHelper

  before(:each) do
    @options= Tget::Main.default_opts
    @options['silent_mode']=true
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    @options['scraper_dir']= tmp_dir
    FileUtils.mkdir_p File.join( tmp_dir, '100')
    new_file File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper
    FileUtils.touch @options['downloaded_files']
    extend Debug
    these_be_options @options
  end

  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end

  it "Should not match X Factor Australia when searching for X Factor" do

  end
  it "Should not match Monster House 2006 SWESUB DVDRip when searching for House"
  it "Should not match Will And Grace Season 8 when searching for Will And Grace"
  it "Should not match s01e13 when last episode downloaded was s01e14"
  it "Should be able to match 'Season 1 Episode 2' as 's01e02'"
  it "Should be able to match '1x12' as 's01e12'"
  it "Should be able to match a date like '2011.10.11' in lieu of an episode ID"
  it "Should be able to match an episode ID / date with and without an accompanying title"
  it "Should be able to match and include a year if found"
  it "Should not match or include either year if two are found"
  it "Should be able to match a show with a roman numeral in it" do
    #The Walking Dead Season Two Episode Four The Long Walk Home Part II
  end
  it "Should be able to match 's01e01e02' and 's01e01-02'"
  it "Should be able to match 'Penn & Teller' when searching for 'Penn And Teller'"  
  it "Should be able to match '701' as 's07e01'"
  it "Should be able to match 'S01.E01' as 's01e01'"
end
