class Slot < ActiveRecord::Base

	def double?
		@nextSlot = Slot.where(appointment: self.appointment+15.minutes,doctor_id: self.doctor_id).first
		doubleValue = false
		if @nextSlot and @nextSlot.available
			doubleValue = true
		end
		return doubleValue
	end
end
