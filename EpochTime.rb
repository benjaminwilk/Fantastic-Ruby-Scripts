#!/usr/bin/env ruby
#Changes Epoch time in .bash_history to something readable
#Last Change: November 6, 2012
#Last Edit: Added Commonlib Functionality, made the log naming scheme easier, removed a lambda

require "fileutils"
require "date"
require "optparse"

class Common_library_function
  def common_library_exist
    return File.exists?('CommonLib.rb')
  end

  def common_library_version
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end

  def common_library_load
    if Common_library_function.new.common_library_exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != Common_library_function.new.common_library_version
        `rm -rf /home/nex*/CommonLib.rb `
        `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
      end
    else
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
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
  return value.strftime("%m\\%d\\%y - %H:%M:%S")
}

class Epoch_function
  def epoch_entry
    arg_value = @username
    if arg_value.nil? == true
      print "\nPress 1 to view available bash histories; 0 to quit \nEnter the user you want to see the bash history to: "
      @@name = gets.strip.downcase

      if @@name == "1"
        puts `\nls /home/*/.bash_history`.strip.split(' ')
        puts "\n"
        epoch_entry
      elsif @@name == "0"
        abort("Goodbye")
      end

    else
      @@name = arg_value.strip.downcase
    end
  end

  def epoch_search
      @bash =  "/home/#{@@name}/.bash_history".strip

    if File.exists?(@bash) == false
      abort("Sorry, that directory doesn't exist.")
    end
  end

  def epoch_writer
    #newcopy = Date_time.call(name)
    log_type = "#{@@name}"
    newcopy = Log_File_Creator(log_type)

    FileUtils.cp @bash, newcopy

    puts "Writing..."
    File.open(newcopy, "w") do  |output|
      File.open(@bash).each do |line|
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
end

d1 = Common_library_function.new
d1.common_library_load
d1.common_library_run
epoch = Epoch_function.new
epoch.epoch_entry
epoch.epoch_search
epoch.epoch_writer
