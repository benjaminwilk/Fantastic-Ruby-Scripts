#Changes Epoch time in .bash_history to something readable
#Last Change: November 6, 2012
#Last Edit: Added Commonlib Functionality, made the log naming scheme easier, removed a lambda

require "fileutils"
require "date"
require "optparse"

class Common_library_function
  def common_library_search
    @commonlib_version = `curl http://benwilk.com/CommonVersion.html`.strip
    common_locator = `ls ~/CommonLib.rb`.strip
    if common_locator.empty? == true
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
	end
  end

  def common_library_load
    running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
    if running_version != @commonlib_version
	  puts "Looks like you're using an out of date version of Commonlib..."
      `rm -rf /home/nex*/CommonLib.rb `
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
    else #running_version == commonlib_version
      puts  "You are running #{running_version}"
    end
  end

  def common_library_run
     require './CommonLib.rb'
  end
end

opts = OptionParser.new
options ={}
opts.on("-n username", "--name username", String, "Name of user")do
   |n| @username = n
   end

opts.parse!(ARGV)

AddUp = lambda {|numb|
  value = Time.at(numb)
#  return rightnow("MonthHour")
  return value.strftime("%m\\%d\\%y - %H:%M:%S")
}

#Date_time = lambda {|username|
#  t = Time.now
  #taber = t.strftime("%m-%d-%Y-%T")
#  return "./#{username}_#{taber}.log"
#  return "./#{username}_#{rightnow("MonthTime")}.log"
#}

def UserFind()
  if @username.nil? == true 
  print "\nPress 1 to view available bash histories; 0 to quit \nEnter the user you want to see the bash history to: "
  name = gets.strip.downcase
  else
    name = @username.strip.downcase
  end

  if name == "1"
    puts `\nls /home/*/.bash_history`.strip.split(' ')
    puts "\n"
    UserFind()
  elsif name == "0"
    abort("Goodbye")
  else
    bash =  "/home/#{name}/.bash_history".strip
  end

  if File.exist?(bash) == false 
    abort("Sorry, that directory doesn't exist.")
  end

  #newcopy = Date_time.call(name)
   log_type = "#{name}"
   newcopy = Log_File_Creator(log_type) 

  FileUtils.cp bash, newcopy

  puts "Writing..."
  File.open(newcopy, "w") do  |output|
   File.open(bash).each do |line|
     if line[/#.*$/]
      final  =  line.gsub(/#/, "").strip.to_i
      final = AddUp.call(final)
      output.puts final
     else
      output.puts line
     end
    end
  end
 puts "All done!"
end

UserFind()
