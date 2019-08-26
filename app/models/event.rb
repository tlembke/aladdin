class Event
	 include ActiveModel::Model
	 attr_accessor :day, :month, :year, :title, :cat, :exactDate

	 def self.sorted(events,month,year)
	 		newlist =[]
	 		events.each do |event|
	 		
		 			if event.month and event.month == month and event.year and event.year == year
		 				newlist << event
		 			end

	 		end
	 		return newlist.sort_by &:day



	 end
end
