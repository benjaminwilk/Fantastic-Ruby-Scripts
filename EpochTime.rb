#!/usr/bin/env ruby
#Changes Epoch time in .bash_history to something readable
#Last Change: November 28, 2012

require "fileutils"
require "date"
require "optparse"

class LibraryLoader
  def exist
    return File.exists?('CommonLib.rb')
  end
  def version_check
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end
  def load
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version_check
        `rm -rf /home/nex*/CommonLib.rb `
        `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
      end
    else
      `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
    end
  end
  def run
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

class EpochFunction
  def user_entry
    arg_value = @username
    if arg_value.nil? == true
      print "\nPress 1 to view available bash histories; 0 to quit \nEnter the user you want to see the bash history to: "
      name = gets.strip.downcase
      if name == "1"
        puts Dir["/home/*/.bash_history"]
        user_entry
      elsif name == "0"
        abort("Goodbye")
      end
    else
      name = arg_value.strip.downcase
    end
    name
  end

  def search(name_value)
    bash =  "/home/#{name_value}/.bash_history".strip
    if File.exists?(bash) == false
      abort("Sorry, that directory doesn't exist.")
    end
    bash
  end

  def writer(bash_path, name_value)
    newcopy = Log_File_Creator(name_value)
    FileUtils.cp bash_path, newcopy

    puts "Writing..."
    File.open(newcopy, "w") do  |output|
      File.open(bash_path).each do |line|
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

d1 = LibraryLoader.new
d1.load
d1.run
epoch = EpochFunction.new
name_value = epoch.user_entry
bash_path = epoch.search(name_value)
epoch.writer(bash_path, name_value)
