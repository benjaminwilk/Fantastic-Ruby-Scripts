=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted with nexcess
Last Revision: Oct 12, 2012
Version: 1.0
Last Change: Creation
=end

full_domain_path = `ls /etc/httpd/conf.d/vhost_*`.chomp.split(' ')
domain_name = `ls /etc/httpd/conf.d/vhost_* | awk -F'_' '{print $2}'| awk -F'.conf' '{print $1}'`.chomp.split(' ')
#ip_address = `grep '<VirtualHost*' #{full_domain_path}`
#dug_domain = `dig a #{domain_name} @8.8.8.8`

puts "\n%s %40s %43s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
domain_name.each_index { |x|
  padding = 50

 if domain_name[x] == '000' or domain_name[x] == '0000'
  print ''
 else
  print "#{domain_name[x]}"
  padding = padding.to_i - domain_name[x].length
  print "%0#{padding}s" %[`grep '<VirtualHost .*:80>' #{full_domain_path[x]} | awk -F'<VirtualHost' '{print $2}'|awk -F':' '{print $1}'`.strip.to_s]
  puts "%40s" %[`dig #{domain_name[x]} @8.8.8.8 +noall +short`.strip]
 end
}