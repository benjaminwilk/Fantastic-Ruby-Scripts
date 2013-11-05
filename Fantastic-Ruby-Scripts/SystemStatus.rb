#System status - Checks various services whether they're running or not
#Version 0.01
#Last Changes - November 12, 2012

require 'optparse'

opts = OptionParser.new
Options = {}
opts.on("-q", "--quick", "Quick service output") do
	 Options[:quick] = true
end

opts.parse!

if Options[:quick] == true
       puts "\nSystem Outlook: "
        menus = ["sshd", "httpd", "mysqld", "djbdns"]
        menus.each_index do |x|
       `service #{menus[x]} status`
        end
  exit
end

def Lsws_Status()
    `service lsws status`
    `tail -n20 /usr/local/lsws/logs/error.log`
end

def Httpd_Status()
    lsws = `ls /etc/init.d/lsws`
    if lsws.empty? == false
          Lsws_Status()
     else   
          puts httpd = `service httpd status`
     if httpd.match("subsys")
          `service mysqld restart`
     end
  end
end

def Sshd_Status()
     puts sshd = `service sshd status`
     if sshd.match("subsys")
        print `tail -n20 /var/log/secure`
    end
end

def Mysqld_Status()
     puts mysqld = `service mysqld status`
    if mysqld.match("stopped")
        print `tail -n20 /var/log/mysqld.log`
       `service mysqld restart`
    end
end

def PhpFpm_Status()
    php = `ls /etc/init.d/php-fpm`
    if php.empty? == false
       puts phpfpm = `service php-fpm status`
	 else
	   puts "Php-fpm is not installed"
	 end
end


Httpd_Status()
Sshd_Status()
Mysqld_Status()
PhpFpm_Status()

