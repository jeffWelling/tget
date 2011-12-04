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
describe Tget::DList do
  include TgetSpecHelper

  before(:each) do
    @options= Tget::Main.default_opts
    @options['silent_mode']=true
    @options['downloaded_files']=File.join( Dir.mktmpdir('tget_dlfiles'), 'downloaded_files.txt' )
    extend Debug
    these_be_options @options
    Tget::DList.load @options['downloaded_files']
  end
  after(:all) do
    FileUtils.rm_rf( Dir.glob(File.join( File.dirname( Dir.mktmpdir ),'tget_*')) )
  end
  
  it "Should initialize to contents of file" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    new_file(temp_file, "Fubar#{DLIST_SEP}gonzo\nFubar1#{DLIST_SEP}gonzo1\nFubar2#{DLIST_SEP}gonzo2\n")
    Tget::DList.load temp_file
    Tget::DList.has?('Fubar', 'gonzo').should == true
    Tget::DList.has?('fubar1', 'gonzo1').should == true
    Tget::DList.has?('fubar2', 'gonzo2').should == true
  end
  it "Should add shows" do
    Tget::DList.add event("Fubar","gonzo")
    Tget::DList.has?('Fubar', 'gonzo').should == true
  end
  it "Should err if invalid event is passed" do
    lambda { Tget::DList.add 0 }.should raise_error
  end
    
  it "Should write self to file when saved" do
    temp_file="/tmp/tget/#{rand(99999999999)}_dlist.rb"
    FileUtils.mkdir_p( File.dirname(temp_file) )
    Tget::DList.add event("Fubar","gonzo")
    Tget::DList.save temp_file
    File.exist?(temp_file).should == true
    contents=nil
    File.open(temp_file, 'r') {|file| contents= file.read }
    contents.class.should == String
    contents[/^.*\n/].should == event("Fubar","gonzo")+"\n"
  end
  it "Should never grow larger than MAX_DF" do
    (Tget::DList.max_df.-1).times do
      Tget::DList.add random_string+DLIST_SEP+random_string
    end
    Tget::DList.dump.length.should == (Tget::DList.max_df.-1)
    Tget::DList.add random_string+DLIST_SEP+random_string
    Tget::DList.dump.length.should == Tget::DList.max_df
    Tget::DList.add random_string+DLIST_SEP+random_string
    Tget::DList.dump.length.should == Tget::DList.max_df
  end
  it "Should delete the oldest addition to DList when deleting items" do
    Tget::DList.add 'First Show Ever'+DLIST_SEP+'s01e01'
    Tget::DList.has?('First Show Ever', 's01e01').should == true
    (Tget::DList.max_df.-1).times do
      Tget::DList.add random_string+DLIST_SEP+random_episode_id
    end
    Tget::DList.dump.length.should == Tget::DList.max_df
    Tget::DList.add random_string+DLIST_SEP+random_episode_id
    Tget::DList.has?('First Show Ever', 's01e01').should == false
  end
  it "Should not allow duplicates" do
    Tget::DList.add event('First Show Ever', 's01e01')
    Tget::DList.has?('First Show Ever', 's01e01').should == true
    lambda { Tget::DList.add event('First Show Ever','s01e01') }.should raise_error
  end
  it "Should be able to use DList.found to prevent subsequent scrapers from downloading the same episode" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    @options['download_dir']=Dir.mktmpdir('tget_downloaddir_')
    fake_torrent1= File.join( Dir.mktmpdir('tget_'), 'fake_torrent1_[other.stuff].txt' )
    fake_torrent2= File.join( Dir.mktmpdir('tget_'), 'fake_torrent2_[other.stuff].txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent1) )
    FileUtils.mkdir_p( File.dirname(fake_torrent2) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '100' ))
    fake_torrent1_data="Fubar fubar lorem ipsum et cetera..."
    fake_torrent2_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent1+'1.torrent', fake_torrent1_data+'1' )
    new_file( fake_torrent2+'2.torrent', fake_torrent2_data+'2' )
    srch_mthd_1="
    def search str
      if str[/fubar1/i] 
        unless Tget::DList.has?('Fubar1','s01e01')
          Tget::DList.found( 'Fubar1'+DLIST_SEP+'s01e01' )
          Tget::Result.new( '#{fake_torrent1+'1.torrent'}', 'Fubar1', 's01e01' ) 
        end
      else
        []
      end
    end"
    srch_mthd_2="
    def search str
      if str[/fubar1/i] 
        unless Tget::DList.has?('Fubar1','s01e01')
          Tget::DList.found( 'Fubar1'+DLIST_SEP+'s01e01' )
          Tget::Result.new( '#{fake_torrent2+'2.torrent'}', 'Fubar1', 's01e01' ) 
        end
      else
        []
      end
    end"
    config="Fubar1"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper1.rb'), 
              fake_scraper(1, srch_mthd_1) 
    )
    new_file( File.join(@options['scraper_dir'], '100', 'fakescraper2.rb'), 
              fake_scraper(2, srch_mthd_2) 
    )
    results=Tget::Main.new(@options).run
    
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      File.basename(dir)[/fake_torrent1_\[other\.stuff\]\.txt1\.torrent/].nil?.should == false
      File.basename(dir)[/fake_torrent2_\[other\.stuff\]\.txt2\.torrent/].nil?.should == true
      File.delete(dir)
    }
    results=Tget::Main.new(@options).run
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      File.basename(dir)[/fake_torrent1_\[other\.stuff\]\.txt1\.torrent/].nil?.should == true
      File.basename(dir)[/fake_torrent2_\[other\.stuff\]\.txt2\.torrent/].nil?.should == true
    }
    
  end
end
