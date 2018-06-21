class Register < ActiveRecord::Base
	has_and_belongs_to_many :patients
	has_many :headers

	def members
		regpats=RegisterPatient.where(register_id: self.id)
		members=[]
		regpats.each do |pat|
			members << pat.patient_id
		end	
		return members
	end


	def load(dbh)
			# load special data for register
			# this will require a number of patients to be accessed from the Genie database!!!

			#first get the relevant patient information
			 patient_array=self.members
          	@patients=[]
          	patient_array.each do |patient|
              @patients<< Patient.get_patient(patient.to_s,dbh)
          	end

          	

          	# run through each patient and cells for each special header
          	@patients.each do |patient|
				self.headers.where(special: true).each do |header|
					header.cells.where(patient_id: patient.id).destroy_all
					
					if patient.respond_to?(header.name)
						value=""
						date=""
						note=""
						case header.code
							when "string"
								value=patient.send(header.name)
							when "date"
								date=patient.send(header.name)
							when "note"
								note=date=patient.send(header.name)
						end
						Cell.create(patient_id: patient.id, header_id: header.id, value: value, date: date, note: note )

					
						 
					end
				end	




				
					

			end

		# now save reload date

		self.update(loaded: DateTime.current())




	end

end
