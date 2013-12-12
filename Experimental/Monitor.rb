#Monitor.rb -- Really pulls the room together
#Description: Download this, and it checks to see if newest script versions are running
#Last Edit: December 12th, 2013

require 'fileutils'

class CommonLoad
  def exist
    return File.exists?('CommonLib.rb')
  end
  def version
    return version = `curl -Ls bit.ly/18Gni3l`.strip
  end
  def download()
    puts "Downloading a new version of CommonLib..."
    `curl -Ls bit.ly/1gk6sfo > CommonLib.rb; chmod u+x CommonLib.rb`
  end
  def deletion()
    `rm -rf /home/$SUDO_USER/CommonLib.rb`
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

class FileIntegrity
#  def exist(decision)
#    return File.exists?(Dir.pwd + #{decision})
#  end
end
    

class MainFunction
  def MenuChoices()
    return selection = ["Traffic Analyzer", "Domain Checker", "Epoch Time", "Log Extractor", "Httpd and Vhost Editor", "Database Repair", "Reboot Finder"]
  end
  
#  def Allocation
    allocate = ["TrafficAnalyzer.rb", "DomainChecker.rb"]
#  end
    
  def Main()
    allocate = ["TrafficAnalyzer.rb", "DomainChecker.rb", "EpochTime.rb", "LogExtractor.rb", "HttpdandVhost.rb", "DatabaseRepair.rb", "RebootFinderV2.rb"]
    puts "Monitoring Main Menu"
    looper = Loop_Function.new
    decision = looper.Menu_Loop(MenuChoices()).to_i - 1
    puts allocate[decision]
 #   FileIntegrity.new.exist(allocate)
  end
end

d2 = CommonLoad.new
d2.load
d2.run
MainFunction.new.Main()
