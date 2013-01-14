#!/usr/bin/env ruby
#Database Repair - Fixes corrupt databases, but you'll need good versions available
#Last Modified: January 14, 2012

master = "./database_read.txt"
new = "./final_database.txt"

File.open(new, "w") do |output|
  File.open(master).each_line do |x|
     final = x.scan(/'([^']*)'/)
    output.puts final
  end
end

File.open(new).each do |y|
  spliter = y.strip.split(".")
#  puts "#{spliter[0]} #{spliter[1]}"
 
  filetoaccess = "./#{spliter[0]}_#{spliter[1]}.txt"

  `sed -n '/DROP TABLE IF EXISTS \`#{spliter[1]}\`/,/-- Table structure for table/p' ./#{spliter[0]}.sql  >
 #{filetoaccess}`

  `cat #{filetoaccess} | mysql -uiworx -p47aFja2byphq #{spliter[0]}`
end
