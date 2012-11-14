#Automator for vhost and httpd.conf file
#To Do: add in YN for replacement of old vhost
#Version 2.5
#Last Revision: August 13, 2012

require "fileutils"
require "optparse"

#Options = {}
#opts = OptionParse.new
#opts.on('-v number', '--value number' integer, "Quick run the vhost and httpd.conf changer") do Options[:quick] = true
#end

#opts.parse!

def User_Check()
   rootchecker = `whoami`.strip
   if rootchecker != "root"
     abort("\nThis script requires root access.  \n\nAre you root?\n\n")
   end
end

def Http_Restart()
   puts "Restarting HTTP..."
   `service httpd restart`
end

def VhostFinder()
   vhost = `find /etc/httpd/conf.d/ -name "vhost_0000*"`
   if vhost.empty? != false
     return "Not Installed"
   end

    if File.readlines("/etc/httpd/conf.d/vhost_0000_defaults.conf").grep(/DirectoryIndex index.html/).any? == false
     return "  Old File   "
   else 
     return "  Installed  "
   end
end

def HttpdFinder()
 if File.readlines("/etc/httpd/conf/httpd.conf").grep(/KeepAliveTimeout.15/).any? == true
  return " Incomplete  " 
 else
  return "  Complete   "
 end
end

def ChangeChecker()
  puts "\n\nChecking for changes on the server...\n\n"
  puts "Checking for dummy Vhost file         [#{VhostFinder()}] "
  puts "Checking for httpd.conf file changes  [#{HttpdFinder()}] "
end

def MenuSelector(array)
  array.each_index { |x|
    puts "#{x+1}. #{array[x]}"
  }
  print "Your selection: "
end

def Chooser()
   selection = ["Create dummy vhost", "Change values to httpd.conf file", "Both 1 and 2", "Exit"]

   puts "\nWhat would you like to do: "
    MenuSelector(selection)
    choice = gets.strip
   if choice == '1'
     VhostCreator()
   elsif choice == '2'
     HttpdChanger()
   elsif choice == '3'
     VhostCreator()
     HttpdChanger()
   elsif choice == '4'
     abort("\nGoodbye.\n")
   else 
     puts "Please enter an appropriate number.\n"
     Chooser()
   end
end


def IPGrabber()
   ipaddress = `ifconfig | head -n10 | awk '/inet addr:*/ {print $2}'| awk -F':' '{print $2}'`.strip
   return ipaddress
end

def SeverName()
   serName = `uname -n`
   return serName
end

def ServerLoad()
    load = `cat /proc/loadavg | awk '{print $1" "$2" "$3}'`
   return load
end

def Stats()
   puts "\nServer name: #{SeverName()}"
   puts "Your IP address: #{IPGrabber()}"
   print "Current server load: #{ServerLoad()}" 
end

def VhostCreator()
   puts "\nCreating default vhost file..."
   vhost = "/etc/httpd/conf.d/vhost_0000_defaults.conf"
   vhostfind = VhostFinder().strip

   if vhostfind == "Old File"
     `rm -rf /etc/httpd/conf.d/vhost_0000_defaults.conf`
   end

   `wget -q http://goo.gl/grvPn; chmod a+x vhost.txt`
   vhostcopy = "vhost.txt"

   FileUtils.touch(vhost)

   text = File.read(vhostcopy).gsub("<IP>","#{IPGrabber()}")
File.open(vhost, "w").write(text)

end

def HttpdChanger()
   master = "/etc/httpd/conf/httpd.conf" 

   puts "Making some changes to the httpd.conf file..."
     text = File.read(master)
       replace = text.gsub(/^KeepAliveTimeout .*$/, "KeepAliveTimeout 3")
       replace = replace.gsub(/^MaxClients.*$/, "MaxClients\t     160")
     File.open(master, "w") {|file| file.puts replace }
end

User_Check()
Stats()
ChangeChecker()
Chooser()
Http_Restart()
`rm -rf vhost.txt`
abort ("\nAll done!\n")
