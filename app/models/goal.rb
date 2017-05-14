class Goal < ActiveRecord::Base
	belongs_to :patient
	belongs_to :master
	belongs_to :measure

	def self.autoloads
		theArray= ['general','diabetes','ihd' ,'hypertension','hypothyroid', 'copd', 'asthma','ckd', 'prostateca']
		return theArray
	end
end
