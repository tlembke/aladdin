class Cell < ActiveRecord::Base
	belongs_to :header


	def display
		

		value=""
		
		if header.code == "cb"
			self.value == "1" ? value = "1" : value ="0"
		elsif header.code =="date" or header.code=="consult"
			value=self.date.to_s(:dmy) if self.date

		else
			value=self.value
		end
	
		return value
	end
end
