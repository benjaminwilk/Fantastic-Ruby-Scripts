#!/usr/bin/env ruby
#Automator for vhost and httpd.conf file
#Last Revision: Nov 28, 2012

require "fileutils"
#require "optparse"

#Options = {}
#opts = OptionParse.new
#opts.on('-v number', '--value number' integer, "Quick run the vhost and httpd.conf changer") do Options[:quick] = true
#end

#opts.parse!

class SupportFunctions
  def user_check
    if rootchecker = ENV['USER'] != "root"
      abort("\nThis script requires root access.  \n\nAre you root?\n\n")
    end
  end
  
  def change_report 
    puts "\n\nChecking for changes on the server...\n\n"
    puts "Checking for dummy Vhost file         [#{VhostFunctions.new.search}] "
    puts "Checking for httpd.conf file changes  [#{HttpFunctions.new.search}] "
    puts "Is this server running PHP-FPM        [#{PhpFpmFunctions.new.search}] "
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
    selection = ["Create dummy vhost", "Change values to httpd.conf file", "Check php-fpm log for errors", "Change max children setting in php-fpm", "Both 1 and 2", "Exit"]
    puts "\nWhat would you like to do: "
    choice_display(selection)
    choice = gets.strip.to_i
    if choice == 1
      vhost = VhostFunctions.new
      vhost.creator
    elsif choice == 2
      httpd = HttpFunctions.new
      httpd.change
    elsif choice == 3
      phpfpm = PhpFpmFunctions.new
      phpfpm.running
      phpfpm.logs 
      main_menu
    elsif choice == 4
      phpfpm = PhpFpmFunctions.new
      phpfpm.running
      phpfpm.logs 
      phpfpm.users
      phpfpm.editor
      phpfpm.corrector
    elsif choice == 5
      vhost = VhostFunctions.new
      vhost.creator
      httpd = HttpFunctions.new
      httpd.change
    elsif choice == 6
      abort("\nGoodbye\n")
    else 
      puts "Please enter an appropriate number.\n"
      Chooser()
    end
  end

  def server_name
    serName = ENV['HOSTNAME']
  end

  def ip_return
    ipaddress = `ifconfig | head -n10 | awk '/inet addr:*/ {print $2}'| awk -F':' '{print $2}'`.strip
  end

  def server_load
    load = `cat /proc/loadavg | awk '{print $1" "$2" "$3}'`
  end
end

class PhpFpmFunctions
  def running
    if search == false
      puts "Sorry, it appears this server isn't running PHP-FPM.\n"
      support.new.main_menu
    end
  end
      
  def search
      report = true
    if File.exist?("/etc/php-fpm.d")
      return "    Yes      "
    else
      report = false
      return "     No      "
    end
  end

  def logs
    # WARNING
    puts "\nMax_Children errors found in error log: "
    line_count = 0
    File.open("/var/log/php-fpm/error.log").each_line do |x|
      if x.include?("max_children") == true # or x.include?("WARNING") == true
        puts x
        line_count = line_count + 1
      end
    end
    if line_count == 0 
      puts "Nothing found"
    end
    puts "\n"
    gets
  end

  def corrector(userconf)
    File.open(userconf).each_line do |r|
      if r.grep("max_children")
        puts r
      end
    end
    print "What would you like to change max children to: "
    maxchange = gets.strip
    puts "Making the changes to the requested php-fpm file..."
    text = File.read(userconf)
    replace = text.gsub(/^pm.max_children = .*$/, "pm.max_children = #{maxchange}")
    File.open(userconf, "w") {|file| file.puts replace }
  end

  def users
    puts "PHP-FPM user files: "
    incrementor = 1
    y = []
    Dir.foreach('/etc/php-fpm.d/') do |y|
      next if y == '.' or y == '..' or y == 'vhost-pool.tpl'
      puts "#{incrementor}. #{y = y.to_a}"
      incrementor = incrementor + 1
    end
    puts "0. Quit\n"
  end
  
  def editor
    results = userinput()
    userpath = "/etc/php-fpm.d/#{results}"
    if File.exist?(userpath) == true
      corrector(userpath)
      userconf = "/etc/php-fpm.d/" + #{results} + ".conf"
      if File.exist?(userconf) == false or userpath == 0
        puts "Sorry, doesn't appear that user exists."
        raise "Hello"
      end
    else
    end
#    corrector(userconf)
  end
   
  def userinput() 
    print "Which user would you like to edit: "
    return username = gets.strip
  end   
  
end

class VhostFunctions
  def search
    vhost = `find /etc/httpd/conf.d/ -name "vhost_0000*"`
    if vhost.empty? != false
      return "Not Installed"
    end
    if File.readlines("/etc/httpd/conf.d/vhost_0000_defaults.conf").grep(/DirectoryIndex index.html/).any? == false
      "  Old File   "
    else 
      "  Installed  "
    end
  end

  def creator
    puts "\nCreating default vhost file..."
    vhost = "/etc/httpd/conf.d/vhost_0000_defaults.conf"
    vhostfind = search.strip 
    if vhostfind == "Old File"
      `rm -rf /etc/httpd/conf.d/vhost_0000_defaults.conf`
    end
    `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/vhost.txt > vhost.txt`
    vhostcopy = "vhost.txt"

    FileUtils.touch(vhost)

    text = File.read(vhostcopy).gsub("<IP>","#{SupportFunctions.new.ip_return}")
    File.open(vhost, "w").write(text)
  end
end

class HttpFunctions
  def restart
    puts "Restarting HTTP..."
    `service httpd restart`
  end

  def search
    if File.readlines("/etc/httpd/conf/httpd.conf").grep(/KeepAliveTimeout.15/).any? == true
      " Incomplete  " 
    else
      "  Complete   "
    end
  end

  def change
    master = "/etc/httpd/conf/httpd.conf" 
    puts "Making some changes to the httpd.conf file..."
    text = File.read(master)
    replace = text.gsub(/^KeepAliveTimeout .*$/, "KeepAliveTimeout 3")
    replace = replace.gsub(/^MaxClients.*$/, "MaxClients\t     160")
    File.open(master, "w") {|file| file.puts replace }
  end
  
  def template_removal
    if File.exist?("vhost.txt")
      FileUtils.rm("vhost.txt")
    end
  end
end


support =  SupportFunctions.new
support.user_check
support.server_status
support.change_report
support.main_menu
apache = HttpFunctions.new
apache.restart
apache.template_removal
abort("\nAll done\n")

