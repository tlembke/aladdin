class Member < ActiveRecord::Base
	belongs_to :patient

 def recall
      recall = Recall.find(self.genie_id)

      return recall

  end

  def showTitle
		theText = self.recall.title
		if theText == "Custom"
			unless self.note.blank?
				theText = self.note 
			end
			# make editable
			theText = "<a href='#' data-type='text' data-url='members/" + self.id.to_s + "'  data-resource='member' data-name='note' class='editable'>" + theText + "</a>"
		end
		return theText.html_safe
	end


	 def overdue?
	 	returnValue = false
	 	todayDate=Date.today
	 	if self.nextYear 		
			if self.nextYear < todayDate.year
			 	returnValue = true
			elsif self.nextYear == todayDate.year and (self.nextMonth == nil or self.nextMonth == 0 or self.nextMonth < todayDate.month)
			 	returnValue = true
			elsif self.nextYear == todayDate.year and self.nextMonth == todayDate.month and (self.nextDay == nil or  self.nextDay == 0 or self.nextDay < todayDate.day)
			 	returnValue = true
			end
		end

	 	return returnValue
	 end

  




end
