#!/usr/bin/env ruby

def test1
  puts "Test One Success."
end
def test2
  puts "Test Two Success."
end
def test3
  puts "Test Three Success."
end

Main_Menu =["selection 1", "Selection 2", "Selection 3"]
Corresponding = [method(:test1), method(:test2), method(:test3)]

Main_Menu.each {|x| puts x }
enter = gets.strip

enter = enter.to_i - 1

Corresponding[enter].call 
