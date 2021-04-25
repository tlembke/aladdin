class Booker < ActiveRecord::Base
	belongs_to :clinic

	def age
		age = ((Time.zone.now - self.dob.to_time) / 1.year.seconds).floor
	end

	def nextDate
		      nextDate = nil
		      if nextBooker=Booker.where(dose: 2, genie: self.genie).first
		          nextDate = nextBooker.clinic.clinicdate
		      end
		    return nextDate
    end
end
