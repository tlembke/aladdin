class Goal < ActiveRecord::Base
	belongs_to :patient
	belongs_to :master
	belongs_to :measure

	def self.autoloads
		theArray= ['general','diabetes','ihd' ,'hypertension','hypothyroid', 'copd', 'asthma','ckd', 'prostateca']
		return theArray
	end

	def updateMessage
		if self.updated_at.to_date == Date.today
			message = "Updated today"
		else
			message = "Updated on " + self.updated_at.strftime("%d/%m/%Y")
		end
		return message
	end
end
 