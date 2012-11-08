#Reboot finder version 2!  With less suck.
#Version 2.0
#Last edited: August 28, 2012
#!/usr/bin/env ruby

require 'fileutils'

#sys_name = lambda {
#   t = Time.now
#   taber = t.strftime("%m-%d-%Y-%T")
#   return "./#{name}_reboot_#{taber}.log"
#}

commonlib_version = `curl http://benwilk.com/CommonVersion.html`.strip
common_locator = `ls ~/CommonLib.rb`.strip
  if common_locator.empty? == true
   `curl --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
  end
running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
   if running_version != commonlib_version
     puts "Looks like you're using an out of date version of Commonlib..."
    `rm -rf /home/nex*/CommonLib.rb `
    `curl --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
   else #running_version == commonlib_version
     puts  "You are running #{running_version}"
   end
require './CommonLib.rb'

def LastReboot()
   return lastreboots = `last | awk '/boot/ {$4=""; print}' | head -n10`
end

def HardDrives()
 software = `mount | awk '/md2/ {print}'`
 hardware = `mount | awk '/sd2/ {print}'`

 if software.empty? == false
   return `cat /proc/mdstat` 
 else 
   mega = `MegaCli -PDList -aALL | awk '/Slot/||/Count: /||/Firmware s/||/Inquiry Data/ {print}'`
   return mega
 end
end

def Sysinfo()
   company = `dmidecode | awk '/Manufacturer/||/Product/ {$1=""; print}' | head -n1`.strip
   system = `dmidecode | awk '/Name:/ {print}' | head -n1 | cut -f2 -d: | sed 's/^[[:space:]]//'`.strip
   final = company + " - " + system
   return final
end

def DiskUsage()
   return `df -h`
end

def Smartctl(disks)
   tester = `smartctl -a #{disks}`
   if tester.grep(/not supported/).any? == true
      return "It doesn't appear smartctl is installed"
   else 
      return smart = `echo "\nHard Drive: #{disks}" && smartctl -a #{disks} | awk '/Device M/||/Serial/||/Raw_Read/||/Reallocated/||/Seek_Error/||/Current_Pen/||/Offline_/||/UDMA/||/Zone/ {print}'`
   end
end

def Sarrecords(t)
   if File.directory?("/var/log/sa/") == true
      return `echo "\nLoad Average: \n" &&sar -q | egrep -v "Linux" | awk '/runq/ {print"\t      "$3"  "$4"   "$5"   "$6"  "$7"  "}'|head -n1 && sar -q | egrep -v "Linux|runq|Average" | awk '$5 > 5.0 {print}' && printf "\nMemory Usage: \n" &&  sar -r | awk '/kbmemfree/ {print"\t     "$3" "$4"  "$5"  "$6" "$7"  "$8"   "$9" " $10" "$11}' |head -n1&& sar -r |egrep -v 'Linux|Average:' | awk '$5 > 85.0 && $10 > 80.0 {print}' && printf "\nIO Wait Time: \n" && sar -u | egrep -iv 'Linux|Average:' | awk '/CPU/ {print"   \t  \t  " $3"     "$4"     "$5"   "$6"   "$7"     "$8}' | head -n1 && sar -u | egrep -iv 'Linux|Average|CPU' | awk '$7 > 5.0 {print}'`
   else
     return "It doesn't appear sar is installed\n"
   end
end

def Records(records)
   results =  `cat #{records} | egrep -i 'aborted|Kernel panic|Out of Memory|oom'`
   if results.empty? == true 
     return "Nothing found in #{records}"
   else
     return results
   end
end

def Ipmitool()
   servertype = `ipmitool fru | awk '/Board Product/ {print}'`

   if servertype.grep(/Board Product/).any? == false
      return "It doesn't appear IPMItool is installed."
   else
      return `ipmitool sel list`
   end
end

def FileWrite()
#   t = Time.now
#   taber = t.strftime("%m-%d-%Y-%T")
#   name = `uname -a | awk '{print $2}'`.strip
#   servername =  "./#{name}_reboot_#{taber}.log"
   log_type = "reboot"
   servername = Log_File_Creator(log_type)

   puts "Writing findings to log file..."

   disks = `fdisk -l /dev/sd? | awk '/Disk / {print $2}' | awk -F':' '{print $1}'`.split(' ')
   name = `uname -a | awk '{print $2}'`.strip
   recs = ["/var/log/dmesg", "/var/log/messages"]

     FileUtils.touch(servername)

        File.open(servername, 'w') {|p|
         p.puts "Server: #{name}"
         p.puts "Server Info: #{Sysinfo()}"
         p.puts "Current time: #{Time.now.asctime}\n"
         p.puts "\nRecent Reboots: "
         p.puts "#{LastReboot()}" 
         p.puts "\nDisk Usage: "
         p.puts "#{DiskUsage()}"
         p.puts "\nIpmitool scan: "
         p.puts "#{Ipmitool()}" 
         p.puts "\nHard drive status: "
         p.puts "#{HardDrives()}"
         p.puts "\nSmartctl records: "
           disks.length.times do |x|
             p.puts "#{Smartctl(disks[x])}"
            end 
         p.puts "\nSar records: "
         p.puts "#{Sarrecords(Time.now)}"
    	 p.puts "\nDmesg results: "
  	 p.puts "#{Records(recs[0])}"
 	 p.puts "\n#{recs[1]}:"
         p.puts "#{Records(recs[1])}"
       }
       puts "Done"
       end

FileWrite()
