require 'rubygems'
require 'fuzzy-date'
require 'chronic'
require 'nickel'

str="'June 2017', :guess=>false"


result = Chronic.parse('June 2017', :guess=>false)

puts result

puts result.begin
	
puts result.end


fuzzy_date = FuzzyDate::parse("July 2018")

puts "PARSING: #{ fuzzy_date.original }"

puts "Short date:     #{ fuzzy_date.short       }"
puts "Long date:      #{ fuzzy_date.long        }"
puts "Full date:      #{ fuzzy_date.full        }"
puts "Year:           #{ fuzzy_date.year        }"
puts "Month:          #{ fuzzy_date.month       }"
puts "Day:            #{ fuzzy_date.day         }"
puts "Month name:     #{ fuzzy_date.month_name  }"
puts "Circa:          #{ fuzzy_date.circa       }"
puts "Era:            #{ fuzzy_date.era         }"

puts 'Nickel'
str= "Use the force on July 1st"
str = ARGV[0]
puts str
n=Nickel.parse(str)
puts n.inspect
