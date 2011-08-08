require File.dirname(__FILE__) + "/spec_helper"

describe Tget::Main do
  include TgetSpecHelper

  before(:each) do
    @options= default_opts
  end
=begin
  before(:all) do
    @path = setup_new_git_repo
    @orig_test_opts = test_opts
    @ticgitng = TicGitNG.open(@path, @orig_test_opts)
  end

  after(:all) do
    Dir.glob(File.expand_path("~/.ticgit-ng/-tmp*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
    Dir.glob(File.expand_path("~/.ticgit/-tmp*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
    Dir.glob(File.expand_path("/tmp/ticgit-ng-*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
  end
=end

  it "Should load scrapers into prioritized list" do
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    @options['scraper_dir']= tmp_dir
    FileUtils.mkdir_p( File.join( tmp_dir, '100') )
    new_file( File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper )
    Tget::Main.load_scrapers @options
    Tget::Main.SCRAPERS[100].length.should == 1
  end
  it "Should not load scrapers with prio above MAX_PRIO" do
    tmp_dir= File.join( Dir.mktmpdir( 'tget_' ), 'lib', 'tget', 'scrapers' )
    @options['scraper_dir']= tmp_dir
    FileUtils.mkdir_p( File.join( tmp_dir, '100') )
    FileUtils.mkdir_p( File.join( tmp_dir, (Tget::Main.MAX_PRIO() +1).to_s  ) )
    new_file( File.join(tmp_dir, '100', 'fakescraper.rb'), fake_scraper )
    new_file( File.join(tmp_dir, (Tget::Main.MAX_PRIO() +1).to_s , 'fakescraper_.rb'), fake_scraper('_') )
    Tget::Main.load_scrapers @options
    Tget::Main.SCRAPERS[ (Tget::Main.MAX_PRIO() + 1).to_s ].should == nil
  end
  it "Should exit politely if no config file is found" do
    @options['config_file']=''
    @options['silent_mode']=true
    tget=Tget::Main.new(@options)
    lambda {tget.run(@options)}.should raise_error
  end

  it "Should produce no output with the --silent option enabled"
  it "Should show debugging output with --debug option enabled"
  it "Should read shows from config file"
  it "Should read config options from config file if they exist" do
    @options=default_opts

    config= Tget::Main(@options).load_config
    config[:shows].length.should == 3
  end

  it "Should 'search' a scraper for a show from the config file"
  it "Should continue searching scrapers sequentially until a match is found"
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
