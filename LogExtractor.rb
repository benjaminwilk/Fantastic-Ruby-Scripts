#Old log Extractor - Finds logs on server, and extracts their transfer.log files into main file
#Version 0.7
#Last edited: October 4, 2012
#!/usr/bin/env ruby

commonlib_version = "0.651"
common_locator = `ls ~/CommonLib.rb`.strip
  if common_locator.empty? == true
     `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
  end
running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
  if running_version != commonlib_version
     puts "Looks like you're using an out of date version of Commonlib..."
     `rm -rf /home/nex*/CommonLib.rb `
     `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
   else #running_version == commonlib_version
    puts  "You are running #{running_version}"
  end
require './CommonLib.rb'

def LogGrab()
  print "\nEnter the date you're looking for (Month/Day): "
  longdate = gets.strip.split(/\/| /)
  if longdate[0].length > 3
    month = longdate[0].slice(0..2)
  elsif longdate.length == 1
    LogGrab()
   else
    month = longdate[0]
  end
   day = longdate[1]
   year = `date | awk '{print $6}'`.strip
   grepdate = "#{day}/#{month}/#{year}"
   date = Date.parse("#{day}-#{month}-#{year}").strftime('%m%d%Y').strip
   day = day.to_i + 1
   dayafter = Date.parse("#{day}-#{month}-#{year}").strftime('%m%d%Y').strip

#  dayafter = `find /home/*/var/*/logs/transfer.log-#{date}.zip`.split("\n")
#  daybeforelogs = `find /home/*/var/*/logs/transfer.log-#{daybefore}.zip`.split("\n")
puts logs = `find /home/*/var/*/logs/transfer.log-#{dayafter}.zip && find find /home/*/var/*/logs/transfer.log-#{date}.zip`.split("\n")
#  logs = dayafter.zip(daybeforelogs).flatten

  if logs.empty? == true
    abort("Sorry, it doesn't appear the log files exist.")
  end

 # FileUtils.mkdir "./#{date}"
  FileUtils.touch "./#{date}-transfer.logs"

  logs.each_index { |x|
#    stripped = `find /home/*/var/*/logs/transfer.log-#{date}.zip | awk -F'/' '{print $5}'`.split("\n")
 #   FileUtils.cp "#{logs[x]}", "./#{date}/transfer.log-#{stripped[x]}.zip"
 #   `unzip ./#{date}/transfer.log-#{stripped[x]}.zip -d ./#{date}`
#    `zcat ./#{date}/#{date}-transfer.log >> ./#{date}/transfer.logs`
    `zcat #{logs[x]} >> ./#{date}-transfer.logs`
#    FileUtils.rm "./#{date}/#{date}-transfer.log"
#    FileUtils.rm_rf "./#{date}/transfer.log-#{stripped[x]}.zip"
  }
 return grepdate 
end

def TopIPHitsOld(grepdate)
 date = Date.parse("#{grepdate}").strftime("%m%d%Y")
 puts "\nTop IP hits during #{grepdate}: \n" 
 puts `grep -i '#{grepdate}' ./#{date}-transfer.logs | awk '{print $1}' | sort | uniq -c | sort -nr | head -n20 | sed 's/^[[:space:]]*//'`
end

def TopIPBlockOld(grepdate)
 date = Date.parse("#{grepdate}").strftime("%m%d%Y")
 puts "\nTop IP block hits during #{grepdate}: \n"
 puts `grep #{grepdate} ./#{date}-transfer.logs | cut -d. -f1-3 | sort | uniq -c | sort -nr | head -n20 | sed 's/^[[:space:]]*//'`
end

def DomaintoHitsComparison(grepdate)
 date = Date.parse("#{grepdate}").strftime("%m%d%Y")
 print "What domain would you like to compare: "
 domaincompare = gets.strip
 zipped = `find ./#{date}/transfer.log-#{domaincompare}.zip`
 if zipped.empty? == true
   break("It appears that this domain doesn't exist")
 end
# `unzip ./#{date}/transfer.log-#{domaincompare}.zip -d ./#{date}/transfer#{domaincompare}.log`

 #    transfer = `awk '/Custom/ {print $2}' #{foundomain}`.uniq
  hstart = 01
  hend = 23
  hstart.upto(hend) { |x|
 #   x = x.to_s
 #   if x.length==1
 #     x = "0"+x
 #   end
   print "\nServer hits for 17/Sep/2012:#{zeroadder(x)}:00-59 : "
   puts `cat /home/*/var/*/logs/transfer.log | grep -c '#{rightnow}:#{x}'`
   print `find #{transfer} | awk -F"/" '{print $5"/"$6}'`.strip
   print " hits: "
#    puts `cat #{transfer} | grep -c '#{rightnow}:#{x}'`
   puts `grep -c #{date}:#{zeroadder(x)} #{transfer}`
   x = x.to_i
   x = x.next
  }
end 

def HourlyServerHits(grepdate)
 start = 00
 stop = 23
 date = Date.parse("#{grepdate}").strftime("%m%d%Y")
  start.upto(stop) { |x|
 print "Visitor hits on #{grepdate} between #{zeroadder(x)}:00 - #{zeroadder(x)}:59 :"
 puts `grep #{grepdate}:#{zeroadder(x)} ./#{date}-transfer.logs | wc -l`
 x = x.to_i
 x = x.next
 }
end

def Evidence(grepdate)
  date = Date.parse("#{grepdate}").strftime("%m%d%Y")
  print "\nWould you like to delete the compiled log files? (Y/N): "
  eviden = gets.strip.upcase
  if eviden == "Y"
    FileUtils.rm_rf "./#{date}"
  end
end

def IPLocationFinder()
 print "\nEnter IP to look up: "
 location = gets.strip
 return `lynx -dump -nolist geoiptool.com/en/?IP=#{location} | egrep -i 'Host Name|IP Address|Country|Region|City|Postal|Longit|Lat'`
end

def Menu()
  grepdate = LogGrab()
  begin
   reversal = ["Top IP hits to server", "Top IP block hits to server", "Hourly server hits", "IP Location"]
   puts "\nWhat would you like to do: \n"
   LoopFunction(reversal)
   print "\nYour choice: "
   menuchoice = gets.strip
   if menuchoice == "1"
     TopIPHitsOld(grepdate)
   elsif menuchoice == "2"
     TopIPBlockOld(grepdate)
   elsif menuchoice == "3"
     HourlyServerHits(grepdate)
   elsif menuchoice == "4"
     puts IPLocationFinder() 
   elsif menuchoice == "0"
     Evidence(grepdate)
   else
     Menu()
   end 
  end while RunAgain() == "Y"
   Evidence(grepdate)
   SelfDestruct()
#   exit 1
end    

Menu()
