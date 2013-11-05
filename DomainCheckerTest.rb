=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted
Last Revision: Oct 31, 2012
Version: 1.0
=end

class DomainCheck

	def vhost_grab
		puts full_domain_path = `ls /etc/httpd/conf.d/vhost_* | grep -v 000_defaults.conf`.chomp.split(' ')
	end
end
=begin
  full_domain_path = `ls /etc/httpd/conf.d/vhost_* | grep -v 000_defaults.conf`.chomp.split(' ')
  domain_name = []
  full_domain_path.each_index do |x|
     domain_name[x] = `echo '#{full_domain_path[x]}' | awk -F'/' '{print $5}' | awk -F'vhost_' '{print $2}' | awk -F'.conf' '{print $1}'`.strip
  end


  puts "\n%s %40s %43s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
  domain_name.each_index { |x|
    padding = 50
    print "#{domain_name[x]}"
    padding = padding.to_i - domain_name[x].length
    print "%0#{padding}s" %[`grep '<VirtualHost .*:80>' #{full_domain_path[x]} | awk -F'<VirtualHost' '{print $2}'|awk -F':' '{print $1}'`.strip.to_s]
    puts "%40s" %[`dig #{domain_name[x]} @8.8.8.8 +noall +short`.strip]
  }
=end

d1 = DomainCheck.new
d1.vhost_grab

