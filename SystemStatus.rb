#System status - Checks various services whether they're running or not
#Version 0.01
#Last Changes - November 12, 2012

#menus = ["sshd", "httpd", "mysqld"]
#menus.each_index do |x|
#`service #{menus[x]} status`
#end

def Httpd_Status()
	puts httpd = `service httpd status`
	if httpd.match("subsys")
#		20.times do |x|
		`service mysqld restart`
	end
end

def Sshd_Status()
	puts httpd = `service httpd status`
     if httpd.match("subsys")
#       20.times do |x|
	  print `tail -fn20 /var/log/httpd/error.log`
     end
end 

def Mysqld_Status()
	puts mysqld = `service mysqld status`
	if httpd.match("stopped")
		print `tail -fn20 /var/log/mysqld.log`
		`service mysqld restart`	
	end
end

def PhpFpm_Status()
  php = `ls /etc/init.d/php-fpm` 
  if php.exists? == true
	puts phpfpm = `service php-fpm status`
  else
    puts "Php-fpm is not installed"
  end
end

Httpd_Status()
Sshd_Status()
Mysqld_Status()
PhpFpm_Status()
