#COMMONLIB VERSION 0.80
#Change date: December 12, 2013
#Last edit: The Loop function is just getting bigger and more intrusive, adding in a script version check!  Oh joy!  I'm sure there won't be any bugs at all and it will be a Christmas Miracle!

#Loop used for menus -- counts the amount of elements to loop, displays them along with a number along-side
class Loop_Function
  def Menu_Loop(elements)
    elements.push("Quit")
    elements.each_index { |x|
      if elements[x].eql?("Quit")
        puts "0. #{elements[x]}"
      else
        puts "#{x+1}. #{elements[x]}"
      end
    }
    print "\nYour selection: "
    decision = gets.strip
    if decision == 0
      puts "\nGoodbye\n"
      exit
    end
    return decision
  end
end

#Requires user to be Root before letting user use script.
class RootAccess
  def StatusCheck
    state = ENV['USER'].strip
    if state =~ /nex*/
      abort("\n\nSorry, this script will need to be run as root.\n\n\n")
    end
  end
end

class Shutdown
  def Again()
   # choice = ""
    print "\nWould you like to check more (Y/N): "
    choice = gets.strip.upcase
    if choice == "Y"
      MainFunction.new.MainMenu()
    elsif choice =="N"
      abort("\nGoodbye")
    else
      Again()
    end
  end

  def Deletion
    Dir["CommonLib.rb"]
  end
end

class ScriptVersionCheck
  def WhatVersionAmI
    File.read("./TrafficAnalyzerTest.rb").match(/#Version.*/)
  end

  def CurrentVersion
    curVersion = `curl -Ls bit.ly/IRXoPX
  end

  def downloader()
    puts "Looks like you're using an out of date version of #{}"
  end

  def VersionCompare
    running = WhatVersionAmI.to_i
    serverside = CurrentVersion.to_i
    if running < serverside
      downloader()
    end
  end

#bit.ly/IRXoPX -- Traffic Analyzer
#bit.ly/1kDIbhG -- Domain Checker

end 


#Displays server's name -- useful for log files
  def CommonName()
   return ENV["HOSTNAME"].strip
  end

#Asks user to input a specific hour, and will return to function
  def SpecifyTime(printblock)
#   print "\nIs there a specific hour you would like to see: "
    print "\n#{printblock} "
    return spectime = gets.strip
  end

#Checks to see if user wants to run again
  def RunAgain()
    print "\nWould you like to run again? (Y/N): "
    return runner = gets.strip.upcase
  end

  def Log_File_Creator(log_type)
#    t = Time.now
  #  current_time = Time.now.strftime("%m-%d-%Y-%T")
    current_time =  Time_Format("monthtime")
    name = `uname -n`.strip
    return "./#{name}_#{log_type}_#{current_time}.log"
  end

#A time function that got really screwed up, trying to implement arguments for long time version and short
#class Timedisplay
  def Time_Format(*num_value)
    num_value[0] = num_value[0].downcase
    if num_value[0] == "monthhour"
      return Time.now.strftime("%m/%d/%Y - %H:%M:%S")
    elsif num_value[0] == "hour"
      return Time.now.strftime("%H:%M:%S")
    elsif num_value[0].eql?("date")
      return Time.now.strftime("%d/%b/%Y")
    elsif num_value[0] == "monthtime"
      return Time.now.strftime("%m-%d-%Y-%T")
    else 
      fail("Requires accompanying argument.")
  end
 end
#end
 
#  def TheTime()
#   return Time.now.strftime("%H%M%S")
#  end

#Used for looking through transfer logs that need a zero in front of the hour
  def zeroadder(x)
    x = x.to_s
    if x.length == 1
      return x = "0" + x
    else
      return x
    end
  end

#User input IP, returns to function
class IPOptions
  def IPcheck()
    print "What IP address or domain would you like to check (keep blank to go back): "
    return ipaddy = gets.strip
  end

#Runs IP address through geoiptool which will show location of IP
  def IPLocationFinder()
    ipcheck = IPcheck()
    if ipcheck.empty? == false
      return `whois #{IPcheck}`
    end
  end
end

#Removes commonlib library at the end of the script
  def CommonLib_Remover()
    puts "Goodbye"
    File.delete("./CommonLib.rb") #`rm -rf ./CommonLib.rb`
  end

