class Register < ActiveRecord::Base
	has_and_belongs_to_many :patients

	def members
		regpats=RegisterPatient.where(register_id: self.id)
		members=[]
		regpats.each do |pat|
			members << pat. patient_id
		end	
		return members
	end

end
