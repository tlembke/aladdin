class Provider < ActiveRecord::Base
	def freeCount(theStartDate,noDays=1)
		startDateTime = theStartDate.beginning_of_day
		# we don't want to count Saturdays and Sundays
		finishDate=theStartDate
		i=1
		while i < noDays
			unless finishDate.saturday? or finishDate.sunday?
				i=i+1
			end
			finishDate=finishDate + 1.days
		end
		finishDateTime=finishDate.end_of_day
		freeCountCount = Slot.where('doctor_id = ? and available = ? and appointment BETWEEN ? AND ?', self.genie_id, true, startDateTime, finishDateTime).count
		return freeCountCount
	end
	def nextAvailable(theStartDate)
		startDateTime = theStartDate.beginning_of_day
		nextAvailableAppt = Slot.where('doctor_id = ? and available = ? and appointment > ?', self.genie_id, true, startDateTime).order(:appointment).first
	
		return nextAvailableAppt
	end
	def freesThisDay(theStartDate)
		frees = Slot.where('doctor_id = ? and available = ? and appointment between ? and ?', self.genie_id, true, theStartDate.beginning_of_day, theStartDate.end_of_day).order(:appointment).all
		return frees
	end
	def self.providerStr
	    provider_ids = Provider.pluck(:genie_id)
        providerStr = provider_ids.join( " or ProviderID = ")
        providerStr = "ProviderID = " + providerStr
        return providerStr
     end
end
