require 'rubygems'
require 'mechanize'
require 'logger'
require 'fileutils'


a = Mechanize.new { |agent|
 agent.user_agent_alias = 'Mac Safari'
 #agent.open_timeout=5
   #agent.read_timeout=5
   agent.ssl_version, agent.verify_mode = 'SSLv3',
  OpenSSL::SSL::VERIFY_NONE
  }

a.log = Logger.new('mechanize.log')
a.keep_alive = false

page = a.get('http://git-scm.com/book/en/Getting-Started')

FileUtils.rm_rf 'g' if Dir.exists?('g')
Dir.mkdir("g")

loop do
    begin
      title=page.parser.css("body#documentation div.inner div#content-wrapper div#content div#main.book h1")
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
