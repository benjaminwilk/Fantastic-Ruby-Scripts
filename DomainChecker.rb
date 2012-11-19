#!/usr/bin/env ruby
=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted
Last Revision: Nov 14, 2012
Version: 2.0
=end

class Domain_check
  def vhost_grab
    return full_domain_path = `ls /etc/httpd/conf.d/vhost_* | grep -v 000_defaults.conf`.chomp.split(' ')
  end

  def vhost_stripper
    prefix =  Domain_check.new.vhost_grab
    vhost_stripped = []
    prefix.each_index do |x|
      vhost_stripped[x] = `echo '#{prefix[x]}' | awk -F'vhost_' '{print $2}' | awk -F'.conf' '{print $1}'`
    end
    return vhost_stripped
  end

  def vhost_display
    puts "\n%s %40s %43s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
    final_vhost = vhost_stripper
    final_vhost.each_index { |x|
      padding = 50
      print final_vhost[x].strip
      padding = padding.to_i - final_vhost[x].length
      print "%0#{padding}s" %[`grep '<VirtualHost .*:80>' #{Domain_check.new.vhost_grab[x]} | awk -F'<VirtualHost' '{print $2}'|awk -F':' '{print $1}'`.strip.to_s]
      puts "%40s" %[`dig #{final_vhost[x].strip} +short`]
    }
  end
end

d1 = Domain_check.new
d1.vhost_display
