#!/usr/bin/env ruby
#SysWatch.rb - Shamelessly stolen from Eugene, rewritten in Ruby to check the system every so often for various stats
#Change History: Tried adding in a logging function, but it didn't work out as I intended.  Removed the functionality, but might work on it longer.
#Last Edit: Feb 21, 2013

require 'fileutils'
require 'optparse'

class CommonLoad
  def exist
    return File.exists?('CommonLib.rb')
  end

  def version
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end

  def download()
    `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
  end

  def deletion()
    `rm -rf /home/nex*/CommonLib.rb`
  end

  def verifier_uptime
    if version.match('404')
     puts "Looks like the version verifier is down..."
     deletion()
     download()
    end
  end

  def load
    verifier_uptime
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version
        deletion()
        download()
      end
    else
      download()
    end
   end

  def run
    require './CommonLib.rb'
  end
end

#@duration = nil

options = {}
opts = OptionParser.new
opts.on("-e EMAIL_ADDRESSS", "--email EMAIL_ADDRESS", String, "Email address of user"){|e| @emailaddy = e}
opts.on("-d time", "--duration time", String, "Time to wait per scan") {|t| @duration = t }

begin
  opts.parse!(ARGV)
end

class Runtime
  def time_set 
   if @duration.nil? == true
      print "Enter the frequency to check system status (num/unit): "
      #timeandwords = gets.downcase.strip
       #@duration = timeandwords
      @duration = gets.downcase.strip
      elsif @duration.match(/\d+$/)
        raise ArgumentError, "Incorrect duration input.  Jam number and word together."
      else
      #timeandwords = @duration.to_s
      @duration = @duration.to_s
      end
   end

  def time_parse
    numb_value = @duration.match(/\d+/).to_s.to_i
    word_value = @duration.match(/[a-z]+/).to_s
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
      system_time_set
    end
      @sleep_time = numericaltime
  end

  def email_set
    if @emailaddy.class == NilClass
      print "\nWhat is the email address you would like to send to: "
      @emailaddy = gets.strip
    end
#    FileWriter(numericaltime)
  end
end

class System_monitor
  def system_emailer(type)
  #   `printf "Server alert on #{CommonName()}\n#{type}" | mail -s "Server alert on #{CommonName()} on #{rightnow("L")}" #{@emailaddy}`
    `printf "Server alert on #{CommonName()}\n#{type}" | mail -s "Server alert on #{CommonName()} on #{Time.now.strftime("%m/%d/%Y - %H:%M:%S")}" #{@emailaddy}`
    puts "Email Sent!"
  end


  def system_load
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

  def system_memory_check
    #grep -E '(Mem|Swap(T|F))' /proc/meminfo | awk '{print $2}'
    type = "Memory usage is high, and is alerting"

    keywords = ["MemFree", "Cached","MemTotal", "SwapFree", "SwapTotal"]
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

  def system_php_usage 
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

  def system_web_traffic
    puts "\nWeb Traffic Connections: "
    connex = ['sort|uniq|', '']
    connection_type = ["Unique Connections", "Total Connections"]
    user_ram = `ls /home/ | grep -Ev 'nex*|mysql|tmp|interworx'`.split(' ')
    connex.each_index do |z|
      connections = `netstat -an | awk '/:80/ || /:443/ {print $5}' | sed -e 's/::ffff://' -e '/0.0.0.0/d' -e '/:::*/d' -e '/::1:443/d' | cut -f1 -d:|#{connex[z]}wc -l`.to_s
      puts "#{connection_type[z]}: #{connections}"
    end
  end

  def system_mysql_status
    mysql_status = `service mysqld status`
    if mysql_status.match(/stopped/) or mysql_status.match(/subsys/)
      return "MySQL is not running. "
    else
      pwd =  File.readlines('/root/.mytop').grep(/pass=.*/).to_s.strip.split('=')
      user =  File.readlines('/root/.mytop').grep(/user=.*/).to_s.strip.split('=')
      return "%s\n%s" %["\nMySQL Data:", `mysqladmin -u #{user[1]} --password=#{pwd[1].strip} status`]
    end
  end
end

class System_file_display
#  def FileWriter(numericaltime)
   def display
    #entire_name = "#{CommonName()}_logger-#{Time.now.strftime("%m-%d-%Y-%H:%M:%S")}.log"
    while true
      puts "\n#{Time.now.strftime("%m/%d/%Y - %H:%M:%S")}"
      puts "---------------------"
      systematic = System_monitor.new
      systematic.system_load
      systematic.system_memory_check
      systematic.system_php_usage
      systematic.system_web_traffic
      systematic.system_mysql_status
      puts "\n"
      sleep(@sleep_time)
    end
    File.close
  end
end

d2 = CommonLoad.new
d2.load
d2.run
system = Runtime.new
system.time_set
system.time_parse
system.email_set
filedisplay = System_file_display.new
filedisplay.display
#TimeEdit()

