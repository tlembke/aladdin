class Booker < ActiveRecord::Base
	belongs_to :clinic

	def age
		age = ((Time.zone.now - self.dob.to_time) / 1.year.seconds).floor
	end
end
