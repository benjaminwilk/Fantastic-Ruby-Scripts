#Anything that needs the CommonLib.rb library should just start from here
#Version 1.0

=begin
common = `find /home/nex*/CommonLib.rb`.strip
if common.empty? == false
    `mv #{common} ~`
else
   `wget -q goo.gl/VyGXf; chmod u+x CommonLib.rb;`
end

if File.read("./CommonLib.rb").grep(/#COMMONLIB VERSION 0.610/).any? == false
   puts "Looks like you're using an out of date version of Commonlib..."
   `rm -rf /home/nex*/CommonLib.rb`
   `wget -q goo.gl/VyGXf; chmod u+x CommonLib.rb;`
else 
  print "You are running "
  puts File.read("./CommonLib.rb").grep(/#COMMONLIB VERSION */).to_s.gsub(/#/,'').downcase 
end

 require "CommonLib.rb"
=end



#Version 2.0

commonlib_version = "0.63"
user_location = `pwd|awk -F'/' '{print $4}'`.to_s.strip
common_locator = `ls /home/nex*/CommonLib.rb`.strip

  if common_locator.empty? == true
     `wget -q goo.gl/VyGXf; chmod u+x CommonLib.rb;`
  else
    commonlib_location = `ls #{common_locator} | awk -F'/' '{print $3}'`.to_s.strip
   if user_location != commonlib_location
      `mv #{common_locator} ~`
   end
  end

running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s

  if running_version != commonlib_version
     puts "Looks like you're using an out of date version of Commonlib..."
     `rm -rf /home/nex*/CommonLib.rb`
     `wget -q goo.gl/VyGXf; chmod u+x CommonLib.rb;`
  elsif running_version == commonlib_version 
    print "You are running #{running_version}"
  else 
    print "Ehhh.... \n"
     `rm -rf /home/nex*/CommonLib.rb` 
     `wget -q goo.gl/VyGXf; chmod u+x CommonLib.rb;`
  end

require './CommonLib.rb'