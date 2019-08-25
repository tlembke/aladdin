class Event
	 include ActiveModel::Model
	 attr_accessor :day, :month, :year, :title, :cat, :exactDate

	 def self.sorted(events,month,year)
	 		newlist =[]
	 		events.each do |event|
	 			begin
		 			if event.month and event.month == month and event.year and event.year == year
		 				newlist << event
		 			end
		 		rescue
		 			debugger
		 		end
	 		end
	 		return newlist.sort_by &:day



	 end
end
