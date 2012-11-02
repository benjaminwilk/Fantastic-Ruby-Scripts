#SysWatch.rb - Shamelessly stolen from Eugene, rewritten in Ruby to check the system every so often for various stats
#Change History: Tried adding in a logging function, but it didn't work out as I intended.  Removed the functionality, but might work on it longer.

require 'fileutils'
require 'optparse'

commonlib_version = "0.63"
user_location = `pwd|awk -F'/' '{print $4}'`.to_s.strip
common_locator = `ls /home/*/CommonLib.rb`.strip
  if common_locator.empty? == true
     `curl --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
  else
    commonlib_location = `ls #{common_locator} | awk -F'/' '{print $3}'`.to_s.strip
   if user_location != commonlib_location
      `mv #{common_locator} ~`
   else
    ;
   end
  end
running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
  if running_version != commonlib_version
     puts "Looks like you're using an out of date version of Commonlib..."
     `rm -rf /home/nex*/CommonLib.rb`
     `curl --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
   elsif running_version == commonlib_version
    puts  "You are running #{running_version}"
  end
require './CommonLib.rb'

@duration = nil
@emailaddy = nil

options = {}
opts = OptionParser.new
opts.on("-e EMAIL_ADDRESSS", "--email EMAIL_ADDRESS", String, "Email address of user") {|e| @email_addy = e }
opts.on("-d time", "--duration time", String, "Time to wait per scan") {|t| @duration = t }
opts.on("-h", "--help", String, "Help Menu")do 
  puts "Help" 
 exit 
end
begin
  opts.parse!(ARGV)
end



def HelpMenu()
  puts "A user defined system monitor that alerts an email user of high than usual loads.\n"
  puts "Usage:\n\truby SysWatch.rb\n\truby SysWatch.rb [option][arg]\n"
  puts "Options:\n\t-d,  --duration \t define time between scans\n-e,  --email \t define email address to send to\n"
end

def TimeEdit()
  if @duration.nil? == true
    print "Enter the frequency to check system status (num/unit): "
    timeandwords = gets.downcase.strip
   else
    @duration = timeandwords
  end
    numb_value = timeandwords.match(/\d+/).to_s.to_i
    word_value = timeandwords.match(/[a-z]+/).to_s
    if word_value.length > 3
      word_value = word_value.slice(0...3)
    end
  
  if word_value == "sec" or word_value == "s"
    numericaltime = numb_value * 1
  elsif word_value == "min" or word_value == "m"
    numericaltime = numb_value * 60
  elsif word_value == "hou" or word_value == "h"
    numericaltime = numb_value * 60 * 60
  else
    puts "Sorry, I don't know what unit of time that is."
    TimeEdit()
  end
 #if @emailaddy.nil? == true 
 if @emailaddy.class != NilClass 
  print "\nWhat is the email address you would like to send to: "
   @emailaddy = gets.strip
 end
  FileWriter(numericaltime)
end

def Emailer(type)
  # emailaddy = 'bwilk@nexcess.net'
#   `printf "Server alert on #{CommonName()}\n#{type}" | mail -s "Server alert on #{CommonName()} on #{rightnow("L")}" #{@emailaddy}`
   `printf "Server alert on #{CommonName()}\n#{type}" | mail -s "Server alert on #{CommonName()} on #{Time.now.strftime("%m/%d/%Y - %H:%M:%S")}" #{@emailaddy}`
   puts "Email Sent!"
 end


def ServerLoad()
  type = "Server load is high, and is alerting."
  puts "\nCurrent Server Load:\n1 Min  5 Min  15 Min"
    loadtriplicate = Array.new
   1.upto(3) do |x|
    loadvalue = `awk '{print $#{x}}' /proc/loadavg`.to_f
    loadtriplicate.push("#{loadvalue}")
    print " %.2f  " %["#{loadvalue}"]
   end
    loadtriplicate = loadtriplicate.collect{ |x| x.to_f }
#    print "#{loadtriplicate[1].class}"
   loadtriplicate.each_index do |r|
    if loadtriplicate[r] > 8.0
      Emailer(type) 
    end
  end
end

def MemoryUsage()
  #grep -E '(Mem|Swap(T|F))' /proc/meminfo | awk '{print $2}'
  type = "Memory usage is high, and is alerting"

  keywords = ["MemFree", "^Cached","MemTotal", "SwapFree", "SwapTotal"]
  memdigit = []
  puts "\n\nMemory Usage:"
 keywords.each_index do |y|
    memdigit = `grep -E '#{keywords[y]}' /proc/meminfo | awk '{print $2}'`.to_i / 1024
    buffer = keywords[y].length - 10
    puts "%s   %#{buffer}d %s" %["#{keywords[y]}", "#{memdigit}", "MB"]
#    puts memdigit = `grep -E '#{keywords[y]}' /proc/meminfo | awk '{print $2}'`.to_i / 1024
    #memdigit/1024
  if memdigit < 50
    Emailer(type)
  end
 end
end

def PHPUsage()
puts "\nUser Memory Usage: "
user_ram = `grep -E 'SuexecUserGroup' /etc/httpd/conf.d/vhost_*| awk '{print $3}'`.split(' ').uniq.sort

user_ram.each_index { |p|
ramused = `ps -Ao user,rss,%cpu,command|grep php|grep -v root | grep #{user_ram[p]} | awk '{print $2}'`.split(' ').collect{ |x|
   x.to_i
}
 ramused = ramused.inject{|z,sum| sum+z}.to_f / 1024

  if ramused == 0.00
    print ''
  else
    puts "%s  %.2f -- %s" %[user_ram[p], ramused, "MB"]
  # puts "  %.2f  %s" %[ramused = ramused.inject{|z,sum| sum+z}.to_f / 1024, "MB"]
#    puts "  %.2f -- %s" %[ramused, "MB"]
 end
}

end

def WebTraffic()
  puts "\nWeb Traffic Connections: "
  connex = ['sort|uniq|', '']
  connection_type = ["Unique Connections", "Total Connections"]
 user_ram = `ls /home/ | grep -Ev 'nex*|mysql|tmp|interworx'`.split(' ')
  connex.each_index do |z|
    connections = `netstat -an | awk '/:80/ || /:443/ {print $5}' | sed -e 's/::ffff://' -e '/0.0.0.0/d' -e '/:::*/d' -e '/::1:443/d' | cut -f1 -d:|#{connex[z]}wc -l`.to_s
    puts "#{connection_type[z]}: #{connections}"

  end
  PHPUsage()
end

def MySQLStatus()
   mysql_status = `service mysqld status`
   if mysql_status.match(/stopped/) or mysql_status.match(/subsys/)
     return "MySQL is not running. "
  else
    pwd =  File.readlines('/root/.mytop').grep(/pass=.*/).to_s.strip.split('=')
    user =  File.readlines('/root/.mytop').grep(/user=.*/).to_s.strip.split('=')
    return "%s\n%s" %["\nMySQL Data:", `mysqladmin -u #{user[1]} --password=#{pwd[1].strip} status`]
  end
end

def FileWriter(numericaltime)
entire_name = "#{CommonName()}_logger-#{Time.now.strftime("%m-%d-%Y-%H:%M:%S")}.log"
#FileUtils.touch(entire_name)
#File.open(entire_name, 'a+') do |x|
  while true
#  puts "\n#{rightnow("L")}" 
   #x.puts "\n#{Time.now.strftime("%m/%d/%Y - %H:%M:%S")}"
   puts "\n#{Time.now.strftime("%m/%d/%Y - %H:%M:%S")}"
   #x.puts "---------------------"
   puts "---------------------"
#   x.puts "\nCurrent Server Load:\n1 Min  5 Min  15 Min"
#   x.print ServerLoad()
   ServerLoad()
   #x.puts MemoryUsage()
   MemoryUsage()
   #x.puts WebTraffic()
   WebTraffic()
   #x.puts MySQLStatus()
   puts MySQLStatus()
   #x.puts "\n"
   puts "\n"
 
  sleep(numericaltime)
  end
File.close
end

TimeEdit()

