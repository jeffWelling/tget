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
require File.dirname(__FILE__) + "/spec_helper"
describe Tget::Config do
  include TgetSpecHelper

  before(:each) do
    @options= Tget::Main.default_opts
    @options['download_dir']=Dir.mktmpdir('tget_downloaddir_')
    @options['silent_mode']=true
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    tmp_cfg_dir= File.join( Dir.mktmpdir('tget_cfg'), '.tget_cfg')
    @options['scraper_dir']= tmp_dir
    @options['config_file']= tmp_cfg_dir
    FileUtils.mkdir_p( File.join( tmp_dir, '100') )
    FileUtils.mkdir_p( File.dirname(tmp_cfg_dir) )
    new_file( File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper )
    extend Debug
    these_be_options @options
  end
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end
  
  it "Should return false if there is no config to load" do
    Tget::Config.load_config(@options).should == false
  end
  it "Should load config with a path" do
    new_file( @options['config_file'], "Burn Notice
The Daily Show
The Colbert Report
### Options ###
fu=bar")
    config=Tget::Config.load_config(@options)
    config.has_key?(:shows).should == true
    config[:shows].length.should == 3
    config.has_key?('fu').should == true
  end
  it "Should save config with a path" do
    File.exist?(@options['config_file']).should == false
    config={:shows=>['The Daily Show','The Colbert Report','Burn Notice'], "Fubar"=>"baz"}
    Tget::Config.save_config( config, @options['config_file'] ) 
    File.exist?(@options['config_file']).should == true
  end
  it "Should be able to delete a show from the config" do
    new_file( @options['config_file'], "Burn Notice
The Daily Show
The Colbert Report
### Options ###
fu=bar")
    Tget::Config.del_show( 'Burn Notice', @options )
    config=Tget::Config.load_config(@options)
    config.has_key?(:shows).should == true
    config[:shows].length.should == 2
  end
  it "Should be append a show to the config" do
    new_file( @options['config_file'], "Burn Notice
The Daily Show
The Colbert Report
### Options ###
fu=bar")
    Tget::Config.add_show( 'Futurama', @options )
    config=Tget::Config.load_config(@options) 
    config.has_key?(:shows).should == true
    config[:shows].length.should == 4
    config[:shows].include?('Futurama').should == true
  end
  it "Should be able to print the config"
  it "should be able to verify configs" do
    Tget::Config.verify_opts(nil).should == false
  end
end
