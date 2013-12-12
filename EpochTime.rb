#!/usr/bin/env ruby
#Changes Epoch time in .bash_history to something readable
#Last Change: November 28, 2012

require "fileutils"
require "date"
require "optparse"

class CommonLoad
  def exist
    return File.exists?('./CommonLib.rb')
  end
  def version
    return version = `curl -Ls bit.ly/18Gni3l`.strip
  end
  def download()
    puts "Downloading a new version of CommonLib..."
    `curl -Ls bit.ly/1gk6sfo > CommonLib.rb;chmod u+x CommonLib.rb`
  end
  def deletion
    `rm #{`pwd`.strip}/CommonLib.rb`
     download()
  end
  def verifier_uptime
    if version !~/[0-9]/
     puts "Looks like the version verifier is down..."
     deletion()
    end
  end
  def load
    verifier_uptime
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version
        deletion()
      end
    else
      download()
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

d2 = CommonLoad.new
d2.load
d2.run
epoch = EpochFunction.new
name_value = epoch.user_entry
bash_path = epoch.search(name_value)
epoch.writer(bash_path, name_value)

