class PatientRecall < ActiveRecord::Base
	belongs_to :patient
	has_one  :recall

end
