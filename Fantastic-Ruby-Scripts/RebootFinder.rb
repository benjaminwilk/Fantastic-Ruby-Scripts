#!/usr/bin/env ruby
#Reboot finder 
#Last edited: Nov 29, 2012

require 'fileutils'
#require 'sys/filesystem'

class LibraryLoader
  def exist
    return File.exists?('CommonLib.rb')
  end
  def version_check
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end
  def load
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version_check
        `rm -rf /home/nex*/CommonLib.rb `
        `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
      end
    else
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
    end
  end
  def run
    require './CommonLib.rb'
  end
end

#class HardwareRelated
  def HardDrives()
    software = `mount | awk '/md2/ {print}'`
    hardware = `mount | awk '/sd2/ {print}'`
    if software.empty? == false
      `cat /proc/mdstat` 
    else 
      mega = `MegaCli -PDList -aALL | awk '/Slot/||/Count: /||/Firmware s/||/Inquiry Data/ {print}'`
      #return mega
      mega
    end   
  end

def LastReboot()
  lastreboots = `last | awk '/boot/ {$4=""; print}' | head -n10`
end


def Sysinfo()
  company = `dmidecode | awk '/Manufacturer/||/Product/ {$1=""; print}' | head -n1`.strip
  system = `dmidecode | awk '/Name:/ {print}' | head -n1 | cut -f2 -d: | sed 's/^[[:space:]]//'`.strip
  final = company + " - " + system
  final
end

def DiskUsage()
  `df -h`
end

def Smartctl(disks)
  tester = `smartctl -a #{disks}`
  if tester.grep(/not supported/).any? == true
    return "It doesn't appear smartctl is installed"
  else 
    smart = `echo "\nHard Drive: #{disks}" && smartctl -a #{disks} | awk '/Device M/||/Serial/||/Raw_Read/||/Reallocated/||/Seek_Error/||/Current_Pen/||/Offline_/||/UDMA/||/Zone/ {print}'`
  end
end

def Sarrecords(t)
   if File.directory?("/var/log/sa/") == true
     `echo "\nLoad Average: \n" &&sar -q | egrep -v "Linux" | awk '/runq/ {print"\t      "$3"  "$4"   "$5"   "$6"  "$7"  "}'|head -n1 && sar -q | egrep -v "Linux|runq|Average" | awk '$5 > 5.0 {print}' && printf "\nMemory Usage: \n" &&  sar -r | awk '/kbmemfree/ {print"\t     "$3" "$4"  "$5"  "$6" "$7"  "$8"   "$9" " $10" "$11}' |head -n1&& sar -r |egrep -v 'Linux|Average:' | awk '$5 > 85.0 && $10 > 80.0 {print}' && printf "\nIO Wait Time: \n" && sar -u | egrep -iv 'Linux|Average:' | awk '/CPU/ {print"   \t  \t  " $3"     "$4"     "$5"   "$6"   "$7"     "$8}' | head -n1 && sar -u | egrep -iv 'Linux|Average|CPU' | awk '$7 > 5.0 {print}'`
   else
     "It doesn't appear sar is installed\n"
   end
end

def Records(records)
   results =  `cat #{records} | egrep -i 'aborted|Kernel panic|Out of Memory|oom'`
   if results.empty? == true 
     "Nothing found in #{records}"
   else
     results
   end
end

def Ipmitool()
   servertype = `ipmitool fru | awk '/Board Product/ {print}'`
   if servertype.grep(/Board Product/).any? == false
     "It doesn't appear IPMItool is installed."
   else
     `ipmitool sel list`
   end
end

def FileWrite()
   log_type = "reboot"
   servername = Log_File_Creator(log_type)

   puts "Writing findings to log file..."

   disks = `fdisk -l /dev/sd? | awk '/Disk / {print $2}' | awk -F':' '{print $1}'`.split(' ')
   name = ENV["HOSTNAME"]
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

d1 = LibraryLoader.new
d1.load
d1.run
FileWrite()

