#COMMONLIB VERSION 0.63
#Change date: Oct 11, 2012
#Last edit: General cleanup

  def LoopFunction(elements)
   elements.each_index { |x|
    puts "#{x+1}. #{elements[x]}"
   }
  end

  def CommonName()
   return `uname -n`.strip
  end

  def SpecifyTime()
   print "\nIs there a specific hour you would like to see: "
   STDOUT.flush
   return spectime = gets.strip
  end

  def RunAgain()
   print "\nWould you like to view more stats? (Y/N): "
   return runner = gets.strip.upcase
  end

  def rightnow()
    return Time.now.strftime("%d/%b/%Y")
   #L is short for Long.  Get it.  
#   if arguement == "L"
#    return Time.now.strftime("%m/%d/%Y - %H:%M:%S")
   #'T' is short for time
  # elsif arguement == "T"
#   else
#    return Time.now.strftime("%H:%M:%S")
 #  else 
 #   fail("You need accompanying argument.")
#   end
  end
 
#  def TheTime()
#   return Time.now.strftime("%H%M%S")
#  end

  def zeroadder(x)
    x = x.to_s
    if x.length == 1
    return x = "0" + x
   else
    return x
   end
  end

 def IPcheck()
   print "What IP address would you like to check: "
   return ipaddy = gets.strip
 end

 def IPLocationFinder()
  return `lynx -dump -nolist geoiptool.com/en/?IP=#{IPcheck()} | egrep -i 'Host Name|IP Address|Country|Region|City|Postal|Longit|Lat'`
 end

 def SelfDestruct()
  puts "Goodbye"
  `rm -rf ./CommonLib.rb`
 end
