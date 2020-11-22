module PatientHelper
	def meds_by_cat(medications,category,title)
		return_text=""
		medications.each do |row|
			if ((row['CATEGORY']==category) or (category == "P" and (row['CATEGORY']=="R" or row['CATEGORY']=="I")))
				new_text=""
				if Date.today == row['CREATIONDATE']
					new_text=" (NEW) "
				end
				return_text += "<li><b>"+row['MEDICATION'] + new_text + "</b> " + row['DOSE'] + " " +row['FREQUENCY'] + " " +row['INSTRUCTIONS']+"</li>"
			end
		end
		if return_text != ""
			return_text = "<b>"+title+"</b><ul>"+return_text+"</ul>"
		end
		return return_text.html_safe
	end

	def get_macros
		m = HashWithIndifferentAccess.new #=> {}
		m['b'] = "Blood test"
		m['bf'] = "Blood test (fasting)"
		m['p'] = "Phone me"
		m['r'] = "Make an appointment with me"
		m['a'] = "Make an appointment with "
		m['m'] = "Medication change"

		return m

	end
	def extract_tasks(plan)
		macros=get_macros
		keys=macros.keys
		# see if there are any matches for each key and extract them from text
		tasks=[]
		keys.each do |short|
			short_str="^@"+short
			if plan.match short_str
				# ok, we have a task
				task=macros[short]
				tasks<<task
			end
		end
		return tasks
	end

	def get_goals(condition)
		@goals=Goal.where(condition_id: condition)
		return @goals
	end

	def extract_goal_from_note(note)
		#first get action - should be last thing in note
		actionText = note.match(/(.*)(Goal\r)(.*?)(Action\r|$)(.*)/)
		return actionText
	end

	def get_status(condition, patient)
		
		@status=Status.where(condition_id: condition, patient_id: patient).first
	
		unless @status
			@status=Status.create(condition_id: condition, patient_id: patient,progress: "")
		end
		return @status
	end
end
