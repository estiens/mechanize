require 'rubygems'
require 'mechanize'
require 'logger'
require 'fileutils'

class HelpfulRobot
  attr_accessor :mechanize

  def initialize(log_file, keep_alive=false, user_agent = 'Mac Safari')
    @mechanize = Mechanize.new
    @mechanize.user_agent_alias = user_agent
    @mechanize.keep_alive = keep_alive
    @mechanize.log = Logger.new(log_file)
  end
end

class FolderCleanup
  def self.cleanup
    FileUtils.rm_rf 'g' if Dir.exists?('g')
    Dir.mkdir('g')
  end
end

class Scraper

  attr_accessor :robot, :url

  def initialize(url)
    @robot = HelpfulRobot.new('mechanize.log').mechanize
    @url = url
  end

  def grab_pages
    page = @robot.get(@url)
    loop do
      begin
        title=page.parser.css('body#documentation div.inner div#content-wrapper div#content div#main.book h1')
        print "#{title[0].text} "
        print "#{title[1].text}" unless title[1].nil?
        page.save_as 'g/' + title.text + '.html'
        sleep(0.25)
        break unless page.link_with(:text => 'next')
        page = page.link_with(:text => 'next').click
      rescue Mechanize::ResponseCodeError
        puts 'No reply from server'
      end
    puts "\n--------------------------------------"
    end
  end

end


FolderCleanup.cleanup
scraper = Scraper.new('http://git-scm.com/book/en/Getting-Started')
scraper.grab_pages