require File.dirname(__FILE__) + "/spec_helper"

describe Tget::Main do
  include TgetSpecHelper

  before(:each) do
    @options= default_opts
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
    tget=Tget::Main.new(@options)
    lambda {tget.run}.should raise_error
  end

  it "Should produce no output with the --silent option enabled" do
    @options['logger']=TGET_HISTORY
    @options['silent']=true
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    cli(@options).empty?.should == true
  end

  it "Should show debugging output with --debug option enabled" do
    @options['logger']=TGET_HISTORY
    @options['debug']=true
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    tget=Tget::Main.new(@options).run
    TGET_HISTORY.rewind
    expected_output= <<-EOF
Searching for scrapers in: /Users/jeff/Documents/Projects/tget/spec/tget/scrapers/\#{i}
Debugging output enabled
Adding show 'Fubar1'
Adding show 'Fubar2'
Adding show 'Fubar3'
Config:  
   Shows: --|
            Fubar1
            Fubar2
            Fubar3
   fubar
       1
Results:
    EOF
    expected_output.map {|exp_line| [exp_line,TGET_HISTORY.gets] }.each {|i|
      i[0].should == i[1]
    }
  end

  it "Should read shows from config file" do
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n" )
    @options['config_file']= tmp_file
    config= Tget::Main.new(@options).load_config
    config[:shows].length.should == 3
  end

  it "Should read config options from config file if they exist" do
    @options=default_opts
    tmp_file= File.join( Dir.mktmpdir( 'tget_' ), 'tget_test_config.rb')
    @options['config_file']= tmp_file

    FileUtils.mkdir_p( File.dirname(tmp_file) )
    new_file( tmp_file, "Fubar1\nFubar2\nFubar3\n#{CONFIG_DELIM}\nfubar=1" )
    config= Tget::Main.new(@options).load_config
    config[:shows].length.should == 3
    config['fubar'].should=="1"
  end

  it "Should 'search' a scraper for a show from the config file" do
    @options=default_opts
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
    @options=default_opts
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
      [Tget::Result.new( 'http://localhost/', 'Fubar1', 's01e01' )]
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

  it "Should not explode violently if a scraper cannot be reached"
  it "Should return matching results from the scraper if they are found, or an empty array"
  it "Should download to options['download_dir']"
  it "Should download to options['download_dir'] even when specified as option"
  it "Should create the download directory if it doesn't exist"
  it "Should assign a random name appended with '.torrent' if no name provided" #Can't use show name & ep ID because don't have that info when saving file
  it "Should be able to download torrents with '[' and ']' in the name"
  it "Should save the show and epID when .torrent has been downloaded"
  it "Should not re-download shows that are in options['downloaded_files']"
  it "Should treat options['download_dir'] as relative path if does not start with '/'"
  it "Should be able to do it's work in options['working_dir'] if specified"

end
