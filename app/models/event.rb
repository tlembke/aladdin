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

	 def self.overdue(events)
	 		newlist =[]
	 		todayDate=Date.today
	 		events.each do |event|
	 				if event.year 		
			 			if event.year < todayDate.year
			 				newlist << event
			 			elsif event.year == todayDate.year and (event.month == nil or event.month == 0 or event.month < todayDate.month)
			 				newlist << event
			 			end
			 		end

	 		end
	 		return newlist



	 end
end
