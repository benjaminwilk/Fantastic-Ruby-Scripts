#!/usr/bin/env ruby
=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted
Last Revision: Nov 26, 2012
=end

class DomainCheck
  def vhost_grab
    vhosts = []
    Dir["/etc/httpd/conf.d/vhost_*"].each do |d|
      if d.include? "000"
        print ""
      else
        vhosts.push(d)
      end
    end 
    return vhosts
  end

  def ip_address(vhosts)
    value = []
    vhosts.each_index do |x|
      value[x] = open(vhosts[x]).grep(/<VirtualHost .*:80>/).to_s.gsub!(/:80>/,"").gsub!(/<VirtualHost/, "")
    end
    value 
  end

  def vhost_shortener(long_vhost)
    stripped_vhosts = []
    long_vhost.each_index do |x|
      stripped_vhosts[x] = long_vhost[x].gsub("/etc/httpd/conf.d/vhost_", '').gsub(".conf",'')
    end
    stripped_vhosts
  end

  def domain_display(final_vhost, display_ip)
    puts "\n%s %40s %41s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
    display_ip.each_index do |x|
      padding = 49
      padding = padding.to_i - final_vhost[x].strip.length
      print "%s %#{padding}s %35s" %[final_vhost[x], display_ip[x].strip, `dig #{final_vhost[x].strip} +short`.strip]
      puts "\n"
    end
  end
end

d1 = DomainCheck.new
display_ip = d1.ip_address(d1.vhost_grab)
final_vhost = d1.vhost_shortener(d1.vhost_grab)
d1.domain_display(final_vhost, display_ip)
