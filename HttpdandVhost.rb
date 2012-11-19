#!/usr/bin/env ruby
#Automator for vhost and httpd.conf file
#Version 2.5
#Last Revision: Nov 16, 2012 

require "fileutils"
require "optparse"

#Options = {}
#opts = OptionParse.new
#opts.on('-v number', '--value number' integer, "Quick run the vhost and httpd.conf changer") do Options[:quick] = true
#end

#opts.parse!

class Support_functions
  def user_check
    rootchecker = `whoami`.strip
    if rootchecker != "root"
      abort("\nThis script requires root access.  \n\nAre you root?\n\n")
    end
  end
  
  def change_report 
    puts "\n\nChecking for changes on the server...\n\n"
    puts "Checking for dummy Vhost file         [#{Vhost_functions.new.vhost_search}] "
    puts "Checking for httpd.conf file changes  [#{Http_functions.new.http_search}] "
  end

  def server_status 
    puts "\nServer name: #{server_name}"
    puts "Your IP address: #{ip_return}"
    print "Current server load: #{server_load}" 
  end
 
  def choice_display(array)
    array.each_index { |x|
      puts "#{x+1}. #{array[x]}"
    }
    print "Your selection: "
  end

  def main_menu 
    selection = ["Create dummy vhost", "Change values to httpd.conf file", "Both 1 and 2", "Exit"]
    puts "\nWhat would you like to do: "
    choice_display(selection)
    choice = gets.strip
    if choice == '1'
      vhost = Vhost_functions.new
      vhost.vhost_creator
    elsif choice == '2'
      httpd = Http_functions.new
      httpd.http_change
    elsif choice == '3'
      vhost = Vhost_functions.new
      vhost.vhost_creator
      httpd = Http_functions.new
      httpd.http_change
    elsif choice == '4'
      abort("\nGoodbye.\n")
    else 
      puts "Please enter an appropriate number.\n"
      Chooser()
    end
  end

  def server_name
    serName = `uname -n`
    return serName
  end

  def ip_return
    ipaddress = `ifconfig | head -n10 | awk '/inet addr:*/ {print $2}'| awk -F':' '{print $2}'`.strip
    return ipaddress
  end

  def server_load
    load = `cat /proc/loadavg | awk '{print $1" "$2" "$3}'`
    return load
  end
end

class Vhost_functions
  def vhost_search
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

  def vhost_creator
    puts "\nCreating default vhost file..."
    vhost = "/etc/httpd/conf.d/vhost_0000_defaults.conf"
    vhostfind = vhost_search.strip 
    if vhostfind == "Old File"
      `rm -rf /etc/httpd/conf.d/vhost_0000_defaults.conf`
    end
    #`wget -q http://goo.gl/grvPn; chmod a+x vhost.txt`
    `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/vhost.txt > vhost.txt`
    vhostcopy = "vhost.txt"

    FileUtils.touch(vhost)

    text = File.read(vhostcopy).gsub("<IP>","#{Support_functions.new.ip_return}")
    File.open(vhost, "w").write(text)
  end
end

class Http_functions
  def http_restart
    puts "Restarting HTTP..."
    `service httpd restart`
  end

  def http_search
    if File.readlines("/etc/httpd/conf/httpd.conf").grep(/KeepAliveTimeout.15/).any? == true
      return " Incomplete  " 
    else
      return "  Complete   "
    end
  end

  def http_change
    master = "/etc/httpd/conf/httpd.conf" 
    puts "Making some changes to the httpd.conf file..."
    text = File.read(master)
      replace = text.gsub(/^KeepAliveTimeout .*$/, "KeepAliveTimeout 3")
      replace = replace.gsub(/^MaxClients.*$/, "MaxClients\t     160")
     File.open(master, "w") {|file| file.puts replace }
  end
end


support =  Support_functions.new
support.user_check
support.server_status
support.change_report
support.main_menu
Http_functions.new.http_restart
`rm -rf vhost.txt`
abort("\nAll done\n")
