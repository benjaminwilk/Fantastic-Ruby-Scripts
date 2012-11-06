#TrafficAnalyzer.rb - A fork of the original, less bad
#Version 1.5
#Last edited: November 2, 2012
#Last edit: More cleanup, edited the Commonlib loader
#!/usr/bin/env ruby

commonlib_version = "0.651"
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


def SpecficIP()
   topviews =`grep #{IPcheck()} /home/*/var/*/logs/transfer.log|awk -F'"' '{print $2}'|sort|uniq -c|sort -nrk1|head -n20`
   if topviews.empty? == true
    return "Doesn't look like there is anything here with that IP address."
   else
    return topviews 
   end
end

def HitsPerMinute()
    mhour = '' 
    mstart = 00
    mend = 59

    while mhour == '' or mhour >= '24' or mhour == '\n' or (mhour =~ /[a-z]|[A-Z].*/) do
      mhour = SpecifyTime()
    end

    mstart.upto(mend) { |x|
     moment = "#{rightnow("Date")}:#{zeroadder(mhour)}:#{zeroadder(x)}".strip
     print "Server hits at '#{moment}: "
     puts `cat /home/*/var/*/logs/transfer.log | grep -c #{moment}`
      x = x.to_i
      x = x.next
    }
end

def CompareHitsDomain()
   domain = ''
   hstart = 00
   hend =  Time.now.hour

   while domain == '\n' or domain == '' do 
   print "Specific domain to check (keep blank to quit): "
   domain = gets.strip.downcase
     if domain == '\n' or domain == ''
       MainMenu()
     end
   end
   foundomain = `find /etc/httpd/conf.d/vhost_#{domain}*`.strip.split(' ')#.class
   if foundomain.empty? == true
    abort("Sorry, it doesn't appear that domain exists")
   elsif foundomain.length > 1
    puts "\nYou will need to be a bit more specific with your domain name"
    MainMenu()
   end
   transfer = `awk '/Custom/ {print $2}' #{foundomain}`.split(' ').uniq
   shorten = `find #{foundomain} | awk -F'_' '{print $2}'| awk -F'.conf' '{print $1}'`.strip.capitalize

   hstart.upto(hend) { |x|
    serverhits = `grep '#{rightnow("Date")}:#{zeroadder(x)}' /home/*/var/*/logs/transfer.log |wc -l`.to_i
    if serverhits == 0
      ;
    else
      print "\nServer hits for #{rightnow("Date")}:#{zeroadder(x)}:00-59 : "
      puts serverhits
      print "#{shorten} hits: "
      puts `grep -c '#{rightnow("Date")}:#{zeroadder(x)}' #{transfer} `
   end
    x = x.to_i
    x = x.next
}
end

def HourPerHourHits()
   start = 00
   stop = Time.now.hour

   start.upto(stop) { |x|
#     x = x.to_s
#      if x.length == 1
#        x = "0" + x
#      end
    print "Visitor hits between #{zeroadder(x)}:00 - #{zeroadder(x)}:59 :"
    puts `cat /home/*/var/*/logs/transfer.log | grep -c #{rightnow("Date")}:#{zeroadder(x)}`
    x = x.to_i
    x = x.next
   }
end

def TopIPBlockHits()
   puts "\nTop 20 IP block hits to server: "
  puts `cat /home/*/var/*/logs/transfer.log | grep '#{rightnow("Date")}:#{SpecifyTime()}' | cut -d. -f1-3 | sort | uniq -c | sort -nr | head -n20 | sed 's/^[[:space:]]*//'`
end

def TopIPHitstoServer()
   finals = `cat /home/*/var/*/logs/transfer.log |grep '#{rightnow("Date")}:#{SpecifyTime()}' | cut -d" " -f1 |awk '{print $1}' |sort|uniq -c|sort -nrk1|head -n 20|sed 's/^[[:space:]]*//'`
   return "\nTop 20 IP hits to server:\n#{finals}"
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
    domainhits = `grep '#{rightnow("Date")}:#{zeroadder(hour)}' #{transferlog[x]} | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 20 | sed 's/^[[:space:]]*//'`
    if domainhits.length <= 1
     print ''
    else 
    print "\n"
    print `find #{transferlog[x]}|awk -F"/" '{print $5"/"$7}'`.strip
    print " hits : "
    puts `grep -c '#{rightnow("Date")}:#{zeroadder(hour)}' #{transferlog[x]}`
    puts domainhits
#    puts `grep '#{rightnow}:#{zeroadder(hour)}' #{transferlog[x]} | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 20 | sed 's/^[[:space:]]*//'`
    end
  }
end

def MainMenu()
   menus = ["Top IP hits to server", "Top IP block hits to server", "Server hits - divided by hour", "Server hits - divided by minute", "Compare hits to domain with server hits", "Top transfer log hits","Check what a specific IP is doing", "Check where a specific IP is from"]
   puts "\nWhat analytics would you like to see (0 to quit): "
   LoopFunction(menus) 
   print "Your selection: "
   selector = gets.strip
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
   SelfDestruct()
end


MainMenu()
