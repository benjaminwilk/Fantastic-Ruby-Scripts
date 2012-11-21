#!/usr/bin/env ruby
#TrafficAnalyzer.rb - A fork of the original, less bad
#Version 1.75
#Last edited: November 21, 2012
#Last edit: Conversion of bash commands to ruby
#!/usr/bin/env ruby

class Common_library_function
  def common_library_exist
    return File.exists?('CommonLib.rb')
  end

  def common_library_version
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end

  def common_library_load
    if Common_library_function.new.common_library_exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != Common_library_function.new.common_library_version
        `rm -rf /home/nex*/CommonLib.rb `
        `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
      end
    else
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
    end
  end

  def common_library_run
    require './CommonLib.rb'
  end
end

def SpecficIP()
  ipfinder = []
  b = Hash.new(0)
  ipcheck = gets.strip
  directories = Dir["/home/*/var/*/logs/transfer.log"]
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
  puts "\nTop 20 hits by #{ipcheck}:\n"
  b.each_with_index do |(key, value), index|
    if index < 20
      puts "#{value} #{key}"
    end
  end
end

def HitsPerMinute()
  mhour = ''
  mstart = 00
  mend = 59
  specify = "Is there a specific hour you would like to see: "
  while mhour == '' or mhour >= '24' or mhour == '\n' or (mhour =~ /[a-z]|[A-Z].*/) do
    mhour = SpecifyTime(specify)
  end

  mstart.upto(mend) { |x|
    moment = "#{Time_Format("Date")}:#{zeroadder(mhour)}:#{zeroadder(x)}".strip
    print "Server hits at '#{moment}: "
    count = 0
    logs = Dir["/home/*/var/*/logs/transfer.log"]
    logs.each_index do |y|
      open(logs[y]).each_line do |z|
        if z.include? moment
          count = count + 1
        end
      end
    end
    puts count
    x = x.to_i
    x = x.next
    }
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

def HourPerHourHits()
   start = 00
   stop = Time.now.hour
   log_files = Dir["/home/*/var/*/logs/transfer.log"]

   start.upto(stop) { |x|
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
    x = x.to_i
    x = x.next
   }
end

def TopIPBlockHits()
   specify = "Is there a specific time you would like to see: "
   puts "\nTop 20 IP block hits to server: "
  puts `cat /home/*/var/*/logs/transfer.log | grep '#{Time_Format("Date")}:#{SpecifyTime(specify)}' | cut -d. -f1-3 | sort | uniq -c | sort -nr | head -n20 | sed 's/^[[:space:]]*//'`
end

def TopIPHitstoServer()
  count = 0
  b = Hash.new(0)
  values = []
  vhosts = Dir["/home/*/var/*/logs/transfer.log"]
  vhosts.each_index do |x|
    open(vhosts[x]).each_line do |y|
      if y.include? "#{Time_Format("date")}:"
        values.push(y)
      end
    end
  end
  values.each_index do |a|
    values[a].gsub!(/ .*/,'').strip
  end
  values.sort!
  values.each do |v|
    b[v] += 1
  end
  b = b.sort_by {|key, value| value}.reverse
  puts "\nTop 20 IP hits to server:\n"
  b.each_with_index do |(key, value), index|
    if index < 20
      puts "#{value} #{key}"
    end
  end
end

def Again()
  print "\nWould you like to check more statistics (Y/N): "
  choice = gets.strip.upcase
  if choice == "Y"
    MainMenu()
  elsif choice =="N"
    abort("\nGoodbye")
  else
    Again()
  end
end

def TopHitsPerDomain()
  print "Specific hour (keep blank for entire day): "
  hour = gets.strip
  if hour == '\n' or hour == ' ' or hour == ''
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

def MainMenu()
   menus = ["Top IP hits to server", "Top IP block hits to server", "Server hits - divided by hour", "Server hits - divided by minute", "Compare hits to domain with server hits", "Top transfer log hits","Check what a specific IP is doing", "Check where a specific IP is from"]
   puts "\nWhat analytics would you like to see: "
   loop = Loop_Function.new
   loop.Menu_Loop(menus) 
   print "Your selection: "
   selector = gets.strip
   #timer = Timedisplay.new
    if selector == "7"
      puts SpecficIP()
    elsif selector == "3"
      HourPerHourHits()
    elsif selector == "1"
      puts TopIPHitstoServer()
    elsif selector == "2"
      TopIPBlockHits()
    elsif selector == "4"
      HitsPerMinute()
    elsif selector == "6"
      TopHitsPerDomain()
    elsif selector == "5"
      CompareHitsDomain()
    elsif selector == "8"
      puts IPLocationFinder()
    elsif selector == "0"
      abort("\nGoodbye")
    else 
      MainMenu()
    end
   Again()
   CommonLib_Remover()
end

d1 = Common_library_function.new
d1.common_library_load
d1.common_library_run
MainMenu()
