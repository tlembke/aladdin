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

          	#sort
          	
        



          	

          	# run through each patient and cells for each special header
          	@patients.each do |patient|
				self.headers.where(special: true).each do |header|
					header.cells.where(patient_id: patient.id).destroy_all
					
					# demographic information direct from Genie demographic
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


					
					elsif header.name == "shs"
						@shs =  patient.get_shs_date(dbh)

						Cell.create(patient_id: patient.id, header_id: header.id, value: value, date: @shs, note: note )
					elsif header.name == "epc"
						@epc =  patient.get_epc_count

						Cell.create(patient_id: patient.id, header_id: header.id, value: @epc, date: date, note: note )
					elsif header.code = "consult"
						@lastConsult = patient.get_last_consult_for_reason(patient.id,header.keyword,dbh)
						Cell.create(patient_id: patient.id, header_id: header.id, value: "", date: @lastConsult, note: "" )
	
					end

				


					# item number information

				end	




				
					

			end

		# now save reload date

		self.update(loaded: DateTime.current())




	end

end
