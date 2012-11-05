#COMMONLIB VERSION 0.65
#Change date: Oct 11, 2012
#Last edit: General cleanup

#Loop used for menus -- counts the amount of elements to loop, displays them along with a number along-side
  def LoopFunction(elements)
   elements.each_index { |x|
    puts "#{x+1}. #{elements[x]}"
   }
  end

#Displays server's name -- useful for log files
  def CommonName()
   return `uname -n`.strip
  end

#Asks user to input a specific hour, and will return to function
  def SpecifyTime()
   print "\nIs there a specific hour you would like to see: "
   return spectime = gets.strip
  end

#Checks to see if user wants to run again
  def RunAgain()
   print "\nWould you like to run again? (Y/N): "
   return runner = gets.strip.upcase
  end

#A time function that got really screwed up, trying to implement arguments for long time version and short
  def rightnow(*num_value)
    num_value = num_value.to_s
    #return Time.now.strftime("%d/%b/%Y")
   #L is short for Long.  Get it.  
   if num_value == "MonthHour"
    return Time.now.strftime("%m/%d/%Y - %H:%M:%S")

   elsif num_value == "Hour"
    return Time.now.strftime("%H:%M:%S")

   if num_value == "Date"
    return Time.now.strftime("%d/%b/%Y")

   else 
    fail("Requires accompanying argument.")
    #return Time.now.strftime("%d/%b/%Y")
   end
 end
end
 
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
 def IPcheck()
   print "What IP address would you like to check: "
   return ipaddy = gets.strip
 end

#Runs IP address through geoiptool which will show location of IP
 def IPLocationFinder()
  return `lynx -dump -nolist geoiptool.com/en/?IP=#{IPcheck()} | egrep -i 'Host Name|IP Address|Country|Region|City|Postal|Longit|Lat'`
 end

#Removes commonlib library at the end of the script
 def SelfDestruct()
  puts "Goodbye"
  `rm -rf ./CommonLib.rb`
 end
