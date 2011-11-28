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
    @options['download_dir']=Dir.mktmpdir('tget_downloaddir_')
    @options['downloaded_files']=File.join( Dir.mktmpdir('tget_dlfiles'), 'downloaded_files.txt' )
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

  it "Should load scrapers into prioritized list" do
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    @options['scraper_dir']= tmp_dir
    FileUtils.mkdir_p( File.join( tmp_dir, '100') )
    new_file( File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper )
    tget=Tget::Main.new(@options)
    tget.scrapers[100].length.should == 1
  end

  it "Should not load scrapers with prio above max_prio" do
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    @options['scraper_dir']= tmp_dir
    FileUtils.mkdir_p( File.join( tmp_dir, '100') )
    FileUtils.mkdir_p( File.join( tmp_dir, (Tget::Main.max_prio() +1).to_s  ) )
    new_file( File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper )
    new_file( File.join(tmp_dir, (Tget::Main.max_prio() +1).to_s , 'fakescraper_.rb'), fake_scraper('_') )
    tget= Tget::Main.new(@options)
    tget.load_scrapers @options
    tget.scrapers[ (Tget::Main.max_prio() + 1).to_s ].should == nil
  end

  it "Should exit politely if no config file is found" do
    @options['config_file']=''
    @options['silent_mode']=true
    lambda {Tget::Main.new(@options).run}.should raise_error
  end

  it "Should produce no output with the --silent option enabled" do
    @options['logger']=TGET_HISTORY
    @options['silent_mode']=true
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    Tget::Main.new(@options).run
    cli(@options).empty?.should == true
  end

  it "Should populate download_list but not download torrents with --dry-run" do
    @options['dry_run']=true
    @options['logger']=TGET_HISTORY
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    fake_torrent= File.join( Dir.mktmpdir('tget_'), 'fake_torrent.txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    f_t_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent+'1.torrent', f_t_data+'1' )
    new_file( fake_torrent+'2.torrent', f_t_data+'2' )
    new_file( fake_torrent+'3.torrent', f_t_data+'3' )
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( '#{fake_torrent+'1.torrent'}', 'Fubar1', 's01e01' ) unless Tget::DList.has?('Fubar1','s01e01')
      elsif str[/fubar2/i] 
        Tget::Result.new( '#{fake_torrent+'2.torrent'}', 'Fubar2', 's01e01' ) unless Tget::DList.has?('Fubar2','s01e01')
      elsif str[/fubar3/i] 
        Tget::Result.new( '#{fake_torrent+'3.torrent'}', 'Fubar3', 's01e01' ) unless Tget::DList.has?('Fubar3','s01e01')
      else
        []
      end
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    results=Tget::Main.new(@options).run
    Dir.glob( File.join(File.expand_path(@options['download_dir']),'*')).length.should == 0
    Tget::DList.has?( 'Fubar1', 's01e01' ).should == true
    Tget::DList.has?( 'Fubar2', 's01e01' ).should == true
    Tget::DList.has?( 'Fubar3', 's01e01' ).should == true
  end

  it "Should show debugging output with --debug option enabled" do
    @options['logger']=TGET_HISTORY
    #@options['logger']=$stdout
    @options['debug']=true
    @options['silent_mode']=false
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    these_be_options @options
    Tget::Main.new(@options).run
    TGET_HISTORY.rewind
    expected_output= <<-EOF
Debugging output enabled
Adding show 'Fubar1'
Adding show 'Fubar2'
Adding show 'Fubar3'
Config:  
   fubar
       1
   Shows: --|
            Fubar1
            Fubar2
            Fubar3
Searching for scrapers in: /tmp/tget_20110829-3147-13ioymf/lib/tget/scrapers\#{i}
Loading: /tmp/tget_20110829-3147-13ioymf/lib/tget/scrapers/100/fakescraper.rb
Loaded.
Searching for 3 shows ...
Working with Fakescraper
Searching Fakescraper for Fubar1...
Found 0 results
Searching Fakescraper for Fubar2...
Found 0 results
Searching Fakescraper for Fubar3...
Found 0 results
Results:
No Results.
Done.
Downloading 0 .torrent files...
Done.
    EOF
    expected_output.map {|exp_line| [exp_line,TGET_HISTORY.gets] }.each {|i|
      if (i[1][/^Searching for scrapers/i] rescue false) 
        i[0][/^Searching for scrapers/i].nil?.should_not == true
      elsif (i[1][/^Loading: /i] rescue false)
        i[0][/^Loading: /i].nil?.should_not == true
      elsif (i[1].strip[/Done\.$/i] rescue false)
        #This line of the output is always unique because it prints a timestamp
        next
      else
        i[1].should == i[0]
      end
    }
    TGET_HISTORY.gets.should == nil
  end

  it "Should read shows from config file" do
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n" )
    @options['config_file']= tmp_file
    config= Tget::Config.load_config(@options)
    config[:shows].length.should == 3
  end

  it "Should read config options from config file if they exist" do
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file

    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    config= Tget::Config.load_config(@options)
    config[:shows].length.should == 3
    config['fubar'].should=="1"
  end

  it "Should 'search' a scraper for a show from the config file" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    search_mthd="
    def search str
      TgetSpecHelper::DStore.store str
      []
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    tget=Tget::Main.new(@options)
    tget.run
    TgetSpecHelper::DStore.get[0].should == "Fubar1"
  end

  it "Should continue searching scrapers sequentially until a match is found" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '98' ))
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    search_mthd1="
    def search str
      TgetSpecHelper::DStore.store(\"1|\"+str)
      []
    end"
    search_mthd2="
    def search str
      TgetSpecHelper::DStore.store(\"2|\"+str)
      [Tget::Result.new( 'http://localhost/x.torrent', 'Fubar1', 's01e01' )]
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '98', 'fakescraper1.rb'), fake_scraper("1", search_mthd1) )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper2.rb'), fake_scraper("2", search_mthd2) )
    tget=Tget::Main.new(@options)
    TgetSpecHelper::DStore.clear
    results=tget.run
    TgetSpecHelper::DStore.get[0].should == "1|Fubar1"
    TgetSpecHelper::DStore.get[1].should == "1|Fubar2"
    TgetSpecHelper::DStore.get[2].should == "1|Fubar3"
    TgetSpecHelper::DStore.get[3].should == "2|Fubar1"
    TgetSpecHelper::DStore.get[4].should == "2|Fubar2"
    TgetSpecHelper::DStore.get[5].should == "2|Fubar3"
  end

  it "Should not explode violently if a scraper cannot be reached" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    search_mthd="
    def search str
      raise Errno::ECONNREFUSED
      []
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    tget=Tget::Main.new(@options)
    lambda {tget.run}.should_not raise_error
  end

  it "Should return matching Result objects from the scraper if they are found, or an empty array" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( 'http://localhost/x.torrent', 'Fubar1', 's01e01' )
      elsif str[/fubar2/i] 
        Tget::Result.new( 'http://localhost/x.torrent', 'Fubar2', 's01e01' ) 
      elsif str[/fubar3/i] 
        Tget::Result.new( 'http://localhost/x.torrent', 'Fubar3', 's01e01' ) 
      else
        []
      end
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    tget=Tget::Main.new(@options)
    results=tget.search
    results.length.should == 3
    results[0].class.should == Tget::Result
    results[1].class.should == Tget::Result
    results[2].class.should == Tget::Result
  end

  it "Should download to options['download_dir']" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    fake_torrent= File.join( Dir.mktmpdir('tget_'), 'fake_torrent.txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    f_t_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent+'1.torrent', f_t_data+'1' )
    new_file( fake_torrent+'2.torrent', f_t_data+'2' )
    new_file( fake_torrent+'3.torrent', f_t_data+'3' )
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( '#{fake_torrent+'1.torrent'}', 'Fubar1', 's01e01' )
      elsif str[/fubar2/i] 
        Tget::Result.new( '#{fake_torrent+'2.torrent'}', 'Fubar2', 's01e01' ) 
      elsif str[/fubar3/i] 
        Tget::Result.new( '#{fake_torrent+'3.torrent'}', 'Fubar3', 's01e01' ) 
      else
        []
      end
    end"
    config="Fubar1\nFubar2\nFubar3\n"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    results=Tget::Main.new(@options).run
    i=1
    files=["fake_torrent.txt1.torrent",
           "fake_torrent.txt2.torrent",
           "fake_torrent.txt3.torrent"]
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      files.delete(File.basename(dir)).should_not == nil
      i+=1
    }
    files.empty?.should == true
  end

  it "Should assign a random name appended with '.torrent' if no name provided" do #Can't use show name & ep ID because don't have that info when saving file
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    fake_torrent= File.join( Dir.mktmpdir('tget_'), 'fake_torrent.txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    f_t_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent+'1', f_t_data+'1' )
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( '#{fake_torrent+'1'}', 'Fubar1', 's01e01' )
      else
        []
      end
    end"
    config="Fubar1"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    results=Tget::Main.new(@options).run
    
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      File.basename(dir)[/^\d*\.torrent/].nil?.should == false
    }
  end

  it "Should be able to download torrents with '[' and ']' in the name" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    fake_torrent= File.join( Dir.mktmpdir('tget_'), 'fake_torrent_[other.stuff].txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    f_t_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent+'1.torrent', f_t_data+'1' )
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( '#{fake_torrent+'1.torrent'}', 'Fubar1', 's01e01' )
      else
        []
      end
    end"
    config="Fubar1"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    results=Tget::Main.new(@options).run
    
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      File.basename(dir)[/fake_torrent_\[other\.stuff\]\.txt1\.torrent/].nil?.should == false
    }
  end

  it "Should not re-download shows that are in options['downloaded_files']" do
    @options['config_file']= File.join( Dir.mktmpdir('tget_'), '.tget_cfg' )
    @options['scraper_dir']= File.join( Dir.mktmpdir('tget_'), 'lib', 'tget', 'scrapers' )
    fake_torrent= File.join( Dir.mktmpdir('tget_'), 'fake_torrent_[other.stuff].txt' )
    FileUtils.mkdir_p( File.dirname(fake_torrent) )
    FileUtils.mkdir_p( File.join(@options['scraper_dir'], '99' ))
    f_t_data="Fubar fubar lorem ipsum et cetera..."
    new_file( fake_torrent+'1.torrent', f_t_data+'1' )
    search_mthd="
    def search str
      if str[/fubar1/i] 
        Tget::Result.new( '#{fake_torrent+'1.torrent'}', 'Fubar1', 's01e01' ) unless Tget::DList.has?('Fubar1','s01e01')
      else
        []
      end
    end"
    config="Fubar1"
    new_file( @options['config_file'], config )
    new_file( File.join(@options['scraper_dir'], '99', 'fakescraper.rb'), fake_scraper(nil, search_mthd) )
    results=Tget::Main.new(@options).run
    
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      (File.basename(dir)[/fake_torrent_\[other\.stuff\]\.txt1\.torrent/].nil?.should == false) and
        File.delete(dir)
    }
    results=Tget::Main.new(@options).run
    Dir.glob(File.join(File.expand_path(@options['download_dir']),'*' )) {|dir|
      File.basename(dir)[/fake_torrent_\[other\.stuff\]\.txt1\.torrent/].nil?.should == true
    }
  end
  it "Should add an item to the DList as soon as it is added to results to prevent duplicates from other scrapers"
    #In the design where DList.has? is called while searching and DList.add is called when the file is downloaded
    #a bug can manifest which allows duplicates. This happens when, within the same run of the program, the same
    #episode becomes available on multiple sites. Because all sites are searched before downloading any of the
    #files, tget can end up downloading multiple copies of the same file.
    #If DList.add is called before the file is downloaded, care must be taken to make sure that if the download
    #fails then the episode is removed from DList.

end
