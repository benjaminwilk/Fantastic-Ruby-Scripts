#!/usr/bin/env ruby
=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted
Last Revision: Nov 14, 2012
Version: 2.0
=end

class Domain_check
  def vhost_grab
     return full_domain_path = Dir["/etc/httpd/conf.d/vhost_*"]
   #  full_domain_path.each_index do |x|
   #    full_domain_path[x] = full_domain_path[x].gsub("/etc/httpd/conf.d/vhost_", '').gsub(".conf",'')
   #  end
   #  return full_domain_path
  end

  def zero_remover
    vhost =[]
    vhosts = vhost_grab  
    value = "000"
    vhosts.sort!.each_index do |x|
    if vhosts[x].include? value 
      print ''
    else
       vhost[x] = vhosts[x]
     end 
    end
  return vhost.compact
  end

  def before_after
    stripper = zero_remover
   stripper.each_index do |x|
       stripper[x] = stripper[x].gsub("/etc/httpd/conf.d/vhost_", '').gsub(".conf",'')
    end
    final_vhost = stripper
   return final_vhost
  end

  def vhost_display
    final_vhost = before_after
    puts "\n%s %40s %43s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
    final_vhost.each_index { |x|
      padding = 50
      print final_vhost[x].strip
      padding = padding.to_i - final_vhost[x].length
      print "%0#{padding}s" %[`grep '<VirtualHost .*:80>' #{vhost_grab[x]} | awk -F'<VirtualHost' '{print $2}'|awk -F':' '{print $1}'`.strip.to_s]
      puts "%40s" %[`dig #{final_vhost[x].strip} +short`]
    }
  end
end

d1 = Domain_check.new
d1.zero_remover
d1.vhost_display
#d1.stripper
