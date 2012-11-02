#Changes Epoch time in .bash_history to something readable
#Last Change: October 11, 2012
#Last Edit: Some general cleanup, removed that pesky error, since 'bash' wasn't clean

require "fileutils"
require "date"

AddUp = lambda {|numb|
  value = Time.at(numb)
  return value.strftime("%m\\%d\\%y - %H:%M:%S")
}

Date_time = lambda {|username|
  t = Time.now
  taber = t.strftime("%m-%d-%Y-%T")
  return "./#{username}_#{taber}.log"
}

def UserFind()
  print "\nPress 1 to view available bash histories; 0 to quit \nEnter the user you want to see the bash history to: "
  name = gets.strip.downcase

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

  newcopy = Date_time.call(name)

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
