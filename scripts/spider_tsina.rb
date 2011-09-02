#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'nokogiri'
require 'sqlite3'
require 'redis'

cookie_dir = "."
uniq_redis = Redis.new :host => '192.168.1.142', :port => 6379

cookie = String.new
Dir.chdir(cookie_dir){|dir|
    db = SQLite3::Database.new('cookies.sqlite')
      p = Proc.new{|s| s.to_i.zero? ? 'TRUE' : 'FALSE'}
        db.execute("SELECT  host, isHttpOnly, path, isSecure, expiry, name, value FROM moz_cookies 
                       ORDER BY id DESC"){|r|
                             cookie << [r[0], p.call(r[1]), r[2], p.call(r[3]), r[4], r[5], r[6]].join("\t") << "\n"
                               }
}

agent = Mechanize.new
agent.cookie_jar.load_cookiestxt(StringIO.new(cookie))
result = File.new "result.txt", "a"

def get_intro!(url,agent)
  doc = Nokogiri::HTML(agent.get(url).body)
  sleep 1
  doc.css(".RUI ul li").each do |f|
    next if !f.text.include?("敏感词") or f.text.include?("http")
    return f.text.split("：")[-1]
  end
  return nil
end
##
url_begin ="http://www.example.com/"
1.upto(10000) do |item|
  page = agent.get("#{url_begin}"+ item.to_s)
  doc = Nokogiri::HTML(page.body)
  doc.css(".msgBox .userName a").each do |f|
    url = "http://www.example.com/"+"#{f["href"]}"
    intro = get_intro!(url,agent)
    next if intro.nil? or intro.size <= 6 or intro.include? "_"
    filter_intro = intro.gsub(/\n/,"").gsub(/\ /,"，").gsub(/\s/,"")
#    result << filter_intro + "\n" 
    uniq_redis.sadd("intros",filter_intro)
    puts filter_intro
  end
  sleep 2
end


##写入文件
array = uniq_redis.smembers "intros"
array.each do |item|
  result << item + "\n"
end

result.flush
result.close
