#Version 5.01
#Back after a year break, some condensation, and other minor changes.  
#Threw in a shortened URL to CommonLib version checker

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

d2 = CommonLoad.new
d2.load
d2.run


#class CommonLibLoader
#  def WhereAmI
#    userLocation = `pwd`
#  end

#  def LibLocationExists
#    return WhereAmI
