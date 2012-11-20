#!/usr/bin/env ruby
=begin
DomainChecker.rb: Checks to see if the domains on server are being hosted
Last Revision: Nov 14, 2012
Version: 2.0
=end

class DomainCheck
  def vhost_grab
    vhosts = []
    Dir["/etc/httpd/conf.d/vhost_*"].each { |d|
    if d.include? "000"
      print ""
    else
      vhosts.push(d)
    end
   }
  return vhosts
  end

  def stripper
    vhosts = vhost_grab
    value = []

    vhosts.each_index do |x|
      value[x] = open(vhosts[x]).grep(/<VirtualHost .*:80>/).to_s
      value[x].gsub!(/:80>/,"").gsub!(/<VirtualHost/, "")
    end
  return value 
  end

  def shortened
    vhosts = vhost_grab
    stripped_vhosts = []
    vhosts.each_index do |x|
      stripped_vhosts[x] = vhosts[x].gsub("/etc/httpd/conf.d/vhost_", '').gsub(".conf",'')
    end
  return stripped_vhosts
  end

  def domain_display
    stripped_vhosts = shortened
    value = stripper
    vhosts = vhost_grab
    puts "\n%s %40s %43s" %["Domain name", "IP Address Listed", "IP Address Currently in Use"]
    value.each_index do |x|

      padding = 80
      padding = padding.to_i - vhosts[x].length

      print "%s %#{padding}s %35s" %[stripped_vhosts[x], value[x].strip, `dig #{stripped_vhosts[x].strip} +short`.strip]
      puts "\n"
    end
  end

end

d1 = DomainCheck.new
d1.domain_display
