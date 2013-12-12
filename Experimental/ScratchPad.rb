#!/usr/bin/ruby

class Being
  def initialize name
    @name = name
  end

  def get_name
    @name
  end

end


p1 = Being.new "Jane"

puts p1.get_name
