class Measure < ActiveRecord::Base
	has_many :goals
	has_many :measurements, -> { order(measuredate: :desc) }

	def measureset(patient_id)
		if !(self.local)
			self.measurements << {value: "Drats will have to look them up"}
		else
			measureset = Measurement.where("patient_id = ? AND measure_id = ?", patient_id, self.id).each 
		end
		return measureset
	end

	def chart_local(patient_id,target=nil)
		if target
			self.target = target
		end

		measurevalues=[]
		measureset = self.measurements.where("patient_id = ?", patient_id)
		measureset.each do | mes |
			mes_h = {"MEASUREMENTDATE" => mes.measuredate, "VALUE" => mes.value}

			measurevalues << mes_h
	    end

	    chart = self.chart(measurevalues)
	    return chart

	 end 



	def chart_genie(values,target=nil)
		if target
			self.target = target
		end
		 
			 # value is an array of a hash of all measures
			 # get it back to just this measure
			 measurevalues=[]
			 genie_key=self.field
			 if self.name== "Blood Pressure"
			 	genie_key="SYSTOLIC"
			 	measurevalues=values.dup
			 elsif self.name == "Lipids"
			 	genie_key="CHOLESTEROL"
			 	measurevalues=values.dup
			 else

			 	 values.each do |measureset|
			 	 	mclone=measureset.clone
				 	mclone.delete_if {|key, value| key != genie_key && key != "MEASUREMENTDATE"}
				 	measurevalues << mclone if mclone.count > 1  #MeasurementDate plus one other
			 	 end

			 end

			 chart  = self.chart(measurevalues, genie_key)
			 

		  

		 return chart
	end

	def chart(measurevalues, genie_key="VALUE")
			chart=false
			if measurevalues.count>0
				 
			 	 chart = HashWithIndifferentAccess.new 
				 chart[:values] = measurevalues
				 chart[:description] = self.description
				 chart[:goals]= [self.target]

				 chart[:measure_id]=self.id
				 chart[:xkey] = "MEASUREMENTDATE"
				 chart[:title] = self.name
				 chart[:units] = self.units



				 chart[:labels]=[self.name] 
				 chart[:labels]=["Systolic","Diastolic"] if genie_key=="SYSTOLIC"
				 chart[:labels]=["Total","HDL","LDL","Trigs"] if genie_key=="CHOLESTEROL"
				 chart[:ykeys] = [genie_key]
				 chart[:ykeys].push ("DIASTOLIC") if genie_key=="SYSTOLIC"
				 chart[:ykeys].push("HDL","LDL","TRIGLYCERIDES") if genie_key=="CHOLESTEROL"



				 
				 chart[:last] = measurevalues[0][genie_key]
				 chart[:last_date]=measurevalues[0]["MEASUREMENTDATE"]
				 chart[:last] = measurevalues[0][genie_key].to_s + "/" + measurevalues[0]["DIASTOLIC"].to_s if genie_key=="SYSTOLIC"
				 if measurevalues.count>1
				 	chart[:secondlast] =  measurevalues[1][genie_key]
				 	chart[:diff] = measurevalues[0][genie_key].to_i - measurevalues[1][genie_key].to_i
				 	chart[:last_date]=measurevalues[0]["MEASUREMENTDATE"]
				 	chart[:secondlast_date]=measurevalues[1]["MEASUREMENTDATE"]
				 	chart[:secondlast] = measurevalues[1][genie_key].to_s + "/" + measurevalues[1]["DIASTOLIC"].to_s if genie_key=="SYSTOLIC"
					chart[:caret]=""
				 	if chart[:diff] > 0
				 		chart[:caret]="up"
				 	elsif chart[:diff] < 0
				 		chart[:caret]="down"
				 	end
				 	chart[:diff]=chart[:diff].round(2)
				 end

				 if target
						chart[:gap] = measurevalues[0][genie_key] - target


					 	chart[:caretgap]=""
					 	if chart[:gap]  > 0
					 		chart[:caretgap]="up"
					 	elsif chart[:gap] < 0
					 		chart[:caretgap]="down"
					 	end
					 	chart[:gap]=chart[:gap].round(2)
					 
				 end
			 end
		  

		 return chart
	end


end