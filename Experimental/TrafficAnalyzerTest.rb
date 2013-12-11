#!/usr/bin/env ruby
#TrafficAnalyzerTest.rb
#Version 2.10 BETA 1
#Last edited: December 10, 2013
#Last edit: Removed specific IP checker; didn't work 
#Add in top IP address hitting server -- IP address location

require 'fileutils'

class CommonLoad
  def exist
    return File.exists?('CommonLib.rb')
  end

  def version
    return version = `curl -Ls http://benjaminwilk.com/CommonVersion.html`.strip
  end

  def download()
    puts "Downloading a new version of CommonLib..."
    `curl -Ls bit.ly/1gk6sfo > CommonLib.rb; chmod u+x CommonLib.rb`
  end

  def deletion()
    `rm -rf /home/$SUDO_USER/CommonLib.rb`
     download()
  end

  def verifier_uptime
    if version !~/[0-9]/
     puts "Looks like the version verifier is down..."
     deletion()
    end
  end

  def load
    verifier_uptime
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version
        deletion()
      end
    else
      download()
    end
   end

  def run
    require './CommonLib.rb'
  end
end

def SpecficIP(tmp_file_name)
  ipfinder = []
  b = Hash.new(0)
  ipcheck = IPOptions.new.IPcheck
  directories = Dir[tmp_file_name]
  directories.each_index do |x|
    open(directories[x]).each_line do |y|
      if y.include?(ipcheck)
        ipfinder.push(y)
      end
    end
  end
  ipfinder.each_index do |x|
    ipfinder[x].gsub!(/^.*(\] \")/,"").gsub!(/HTTP.*$/,"")
  end
  ipfinder.sort!
  ipfinder.each do |v|
    b[v] += 1
  end
  b = b.sort_by {|key, value| value}.reverse
#  writertest = FileUtils.touch("Touch_File_TEST")
  puts "\nTop 20 hits by #{ipcheck}:\n"
  b.each_with_index do |(key, value), index|
    if index < 20
      puts "#{value} #{key}"# >> #{writertest}
    end
  end
end

def CompareHitsDomain()
  domain = ''
   hstart = 00
   hend =  Time.now.hour
   transfer_log = ''
   log_files = Dir["/home/*/var/*/logs/transfer.log"]
   while domain == '\n' or domain == '' do
     print "Specific domain to check (keep blank to quit): "
     domain = gets.strip.downcase
     if domain == '\n' or domain == ''
       MainMenu()
     end
   end
   usable_domain = Dir["/etc/httpd/conf.d/vhost_#{domain}*.conf"]
   if usable_domain.empty? == true
     abort("Sorry, it doesn't appear that domain exists")
   end
   open("#{usable_domain}").each_line do |x|
     if x.include? "Custom"
      transfer_log = x
     end
   end
   transfer_log.gsub!("CustomLog","").gsub!("combined","")
   hstart.upto(hend) { |x|
   print "Visitor hits between #{zeroadder(x)}:00 - #{zeroadder(x)}:59 :"
   count = 0
   log_files.each_index do |y|
     open(log_files[y]).each_line do |z|
       if z.include? "#{Time_Format("Date")}:#{zeroadder(x)}"
         count = count + 1
       end
     end
   end
   puts count

   print "#{domain.capitalize} hits: "
   local_count = 0
   open(transfer_log.strip).each_line do |a|
     if a.include? "#{Time_Format("Date")}:#{zeroadder(x)}"
       local_count = local_count +1
     end
   end
   puts local_count
   }
end

class TransferLog
  def log_name 
    user_home = Dir.pwd.strip
    return path = user_home + "/transfer_#{Time.now.strftime("%F%T")}.log"
  end

  def log_creator(file_name)
    FileUtils.touch(file_name)
  end

  def vhost_grab
    vhosts = Dir["/etc/httpd/conf.d/vhost_*"]
  end

  def vhost_stripper(vhosts)
    transfers = []
    vhosts.each_index do |x|
      open(vhosts[x]).each_line do |y|
        if y.include? "CustomLog"
          transfers.push(y)
        end
      end
    transfers.sort!.uniq!
    transfers.each_index do |z|
      transfers[z].gsub!("CustomLog ", "")#.strip!
      transfers[z].gsub!("combined","")#.gsub!("CustomLog ", "")
      transfers[z].strip!
    end
  end
  return transfers
 end

  def placer(transfers, path)
    transfers.each_index do |a|
      open(transfers[a]).each_line do |z|
        open(path, "a+") do |x|
          x.puts z
        end
      end
    end
  end
end

class HitsPerTime
  def HitsPerHour(compiled_file)
    mstart = 00
    mstop = Time.new.hour
    mstart.upto(mstop) do |x|
      print "Total server hits between #{zeroadder(x)}:00 - #{zeroadder(x)}:59 : "
      count = 0
      open(compiled_file).each_line do |y|
        if y.include? "#{Time_Format("Date")}:#{zeroadder(x)}"
          count = count + 1
        end
      end
      puts count
    end
  end

  def HitsPerMinute(compiled_file)
    #puts logs
    mhour = ''
    mstart = 00
    mend = 59
    specify = "What hour would you would like to see: "
    while mhour == '' or mhour >= '24' or mhour == '\n' or (mhour =~ /[a-z]|[A-Z].*/) do
      mhour = SpecifyTime(specify)
    end
    mstart.upto(mend) { |x|
      moment = "#{Time_Format("Date")}:#{zeroadder(mhour)}:#{zeroadder(x)}".strip
      print "Server hits at '#{moment}: "
      count = 0
      open(compiled_file).each_line do |a|
        if a.include? moment
          count = count + 1
        end
      end
      puts count
      x = x.next
    }
  end
end

def TopIPBlockHits()
   specify = "Is there a specific time you would like to see: "
   puts "\nTop 20 IP block hits to server: "
  puts `cat /home/*/var/*/logs/transfer.log | grep '#{Time_Format("Date")}:#{SpecifyTime(specify)}' | cut -d. -f1-3 | sort | uniq -c | sort -nr | head -n20 | sed 's/^[[:space:]]*//'`
end


#######  Working on revamping IP block hits  still needs some work, it just prints one last line 
#def Bricks()
#ipfinder = []
#mystring = []
#b = Hash.new(0)

# File.open(Log_Compiler()).each_line do |x|
#   if x.grep(/^\s/)
#     mystring.push(x[/[^ ]+/])
#   end
#  end
#  mystring.each do |y|
#    y = y.to_s.split(".")
#    ipfinder = y[0] + "." + y[1] + "." + y[2] + "."
#    ipfinder = ipfinder.to_a
#  end
#  ipfinder.sort!
#  ipfinder.each do |v|
#    b[v] += 1
#  end
#  b = b.sort_by {|key, value| value}.reverse
#  puts "\nTop 20 hits by #{ipcheck}:\n"
#  b.each_with_index do |(key, value), index|
#    if index != 20
#      puts "#{value} #{key}"
 #   end
#  end
#end


def TopIPHitstoServer(vhosts)
  count = 0
  b = Hash.new(0)
  values = []
  open(vhosts).each_line do |y|
    if y.include? "#{Time_Format("date")}:"
      values.push(y)
    end
  end
  values.each_index do |a|
    values[a].gsub!(/ .*/,'').strip
  end
  values.sort!.each do |v|
    b[v] += 1
  end
  b = b.sort_by {|key, value| value}.reverse
  puts "\nTop 20 IP hits to server:\n"
  b.each_with_index do |(key, value), index|
    if index < 20
      puts "#{value} #{key}"
    else
      break
#      print ""
    end
  end
end

class Shutdown
  def Again()
   # choice = ""
    print "\nWould you like to check more statistics (Y/N): "
    choice = gets.strip.upcase
    #while choice == "Y" or choice == "N" or choice == "" do
    #  print "\nWould you like to check more statistics (Y/N): "
    #  choice = gets.strip.upcase
    #end
    if choice == "Y"
      MainMenu()
    elsif choice =="N"
#      puts compiled_file
      abort("\nGoodbye")
    else
      Again()
    end
  end

  def Deletion
    Fileutils.del("CommonLib.rb")
#    puts "The Common Library has been deleted: #{require Commonlib.rb}"
  end
end


def TopHitsPerDomain()
  print "Specific hour (keep blank for entire day or enter 'q' to quit): "
  hour = gets.strip
  if hour =~ /[a-z]|[A-Z].*/
   MainMenu()
  elsif hour == '\n' or hour == ' ' or hour == ''
   hour = ""
  end

  transferlog = `wc -l /home/*/var/*/logs/transfer.log | sort -nrk1 | awk '{print $2}' | grep -v 'total'`.split("\n")

  transferlog.each_index { |x|
    domainhits = `grep '#{Time_Format("Date")}:#{zeroadder(hour)}' #{transferlog[x]} | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 20 | sed 's/^[[:space:]]*//'`
    if domainhits.length <= 1
     print ''
    else 
    print "\n"
    print `find #{transferlog[x]}|awk -F"/" '{print $5"/"$7}'`.strip
    print " hits : "
    puts `grep -c '#{Time_Format("Date")}:#{zeroadder(hour)}' #{transferlog[x]}`
    puts domainhits
#    puts `grep '#{rightnow}:#{zeroadder(hour)}' #{transferlog[x]} | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 20 | sed 's/^[[:space:]]*//'`
    end
  }
end

#I know this isn't in proper standards, but I don't want the script to create and compile a new log file every single the main function is run.   
$runtimecount = 0
$logInTmp

#class LogName
#  attr_accessor :$LogInTmp
#end

class MainFunction
  def Menu_Choice()
    menus = ["Top IP hits to server", "Top IP block hits to server", "Server hits - divided by hour", "Server hits - divided by minute", "Compare hits to domain with server hits", "Top transfer log hits","Check what a specific IP is doing"] #, "Check where a specific IP is from"]
  end
  
  #def LogAndRunTime()
   # runtimecount = 0
#	logInTmp
#  end
  
  def Log_Compiler()
    $runtimecount = $runtimecount + 1
    print "Compiling Real-time Logs"
    d1 = TransferLog.new
    tmp_file_name = d1.log_name
    d1.log_creator(tmp_file_name)
    vhosts = d1.vhost_grab
    stripped = d1.vhost_stripper(vhosts)
    final = d1.placer(stripped, tmp_file_name)
#    tmp = LogName.new
#    tmp.LogInTmp = tmp_file_name
#    return tmp.LogInTmp
    $logInTmp = tmp_file_name
    puts "\nDone!"
    return $logInTmp
  end

  def MainMenu()
    puts "\nWhat analytics would you like to see: "
    loop = Loop_Function.new
    decision = loop.Menu_Loop(Menu_Choice()).to_i 
    #print "Your selection: "
    #selector = gets.strip.to_i
#Test tool to see if the application is generating a new transfer file over and over
#    puts $runtimecount

#    if decision == 0
#      puts "Goodbye."
#      exit
    if decision < 0 or decision > Menu_Choice().count
      MainMenu()
    end
 
#    if decision == 8
#       IPOptions.new.IPLocationFinder()
#       MainMenu()
#    end
    if $runtimecount == 0 
      compiled_file = Log_Compiler()
    else 
#      compiled_file = tmp.LogInTmp 
      compiled_file = $logInTmp
    end
#Test method to view compiled file path
#    puts compiled_file
    if decision == 7
      SpecficIP(compiled_file)
    elsif decision == 3
      HitsPerTime.new.HitsPerHour(compiled_file)
    elsif decision == 1
      TopIPHitstoServer(compiled_file)
    elsif decision == 2
      TopIPBlockHits()
    elsif decision == 4
      HitsPerTime.new.HitsPerMinute(compiled_file)
    elsif decision == 6
      TopHitsPerDomain()
    elsif decision == 5
      CompareHitsDomain()
#    elsif decision == 8
#       IPOptions.new.IPLocationFinder()
    else 
      MainMenu()
    end
    Shutdown.new.Again()
    CommonLib_Remover()
  end
end


d2 = CommonLoad.new
d2.load
d2.run
RootAccess.new.StatusCheck
MainFunction.new.MainMenu()
