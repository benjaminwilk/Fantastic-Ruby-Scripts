#!/usr/bin/env ruby
#Database Repair - Fixes corrupt databases, but you'll need good versions available
#Last Modified: Febuary 25th, 2013

class CommonLoad
  def exist
    return File.exists?('CommonLib.rb')
  end
  def version
    return version = `curl -k --silent http://benwilk.com/CommonVersion.html`.strip
  end
  def download()
    `curl -k --silent https://raw.github.com/securitygate/Fantastic-Ruby-Scripts/master/CommonLib.rb > CommonLib.rb; chmod u+x CommonLib.rb`
  end
  def deletion()
    `rm -rf /home/nex*/CommonLib.rb`
  end
  def verifier_uptime
    if version.match('404')
     puts "Looks like the version verifier is down..."
     deletion()
     download()
    end
  end
  def load
    verifier_uptime
    if exist == true
      running_version = File.read("./CommonLib.rb").match(/#COMMONLIB VERSION.*/).to_s.split(' ').slice!(2).to_s
      if running_version != version
        deletion()
        download()
      end
    else
      download()
    end
   end
  def run
    require './CommonLib.rb'
  end
end

class MySQLCredentials
  def Pass 
    return credents = `grep "pass=" /home/nexbwilk/.mytop`.split(/pass=/).to_s.strip
  end
 
  def MySQL_Login
    `mysql -uiworx -p#{Pass}
  end
end


def File_Name()
  print "Enter name of file with database repairs to be made: "
  return DB_List = gets.strip.class
end

#Apparently Ruby 1.8.7 doesn't support 'exist'
def File_Exist()
  if File_Name().exist? 
    puts "Sorry, doesn't appear that filename is correct."
    Menu() 
  end
end

def LogCheck
  File.open("/var/log/mysqld.log").each_line do |y|
    if y.grep("[ERROR]") == true
      puts y
    end
  end
  RunAgain()
  Menu()
end  

def Simple_Repair
  File_Exist()
end

def Advanced_Repair
  File_Exist()
  `cat #{filetoaccess} | MySQLCredentials.new.MySQL_Login`
#end
end

def DB_Name_Changer(DB_List)
  File.open(DB_List).each_line do |x|
    final = x.scan(/'([^']*)'/)
    output.puts final
  end

  File.open(new).each do |y|
    spliter = y.strip.split(".")
    puts "#{spliter[0]} #{spliter[1]}"
    filetoaccess = "./#{spliter[0]}_#{spliter[1]}.txt"  
  end
end


#master = "./database_read.txt"
new = "./final_database.txt"

#  `sed -n '/DROP TABLE IF EXISTS \`#{spliter[1]}\`/,/-- Table structure for table/p' ./#{spliter[0]}.sql  > #{filetoaccess}`


#  `cat #{filetoaccess} | mysql -u#{useraccess} -p#{passaccess} #{spliter[0]}`
#end

def Menu()
  elements = ['Simple Repair', 'Advanced Repair', 'Log Search for errors']
  Loop_Function.new.Menu_Loop(elements)
  print "Your selection: "
  selector = gets.strip.to_i
  puts
  if selector == 1
    Simple_Repair()
  elsif selector == 2
    Advanced_Repair()
  elsif selector == 3
    LogCheck()
  elsif selector == 0
   puts "Goodbye"
   exit
  end
end

d2 = CommonLoad.new
d2.load
d2.run
Menu()
#fileexist()

