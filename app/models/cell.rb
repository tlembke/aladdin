class Cell < ActiveRecord::Base
	belongs_to :header


	def display
		

		value=""
		
		if header.code == "cb"
			value="0"
			self.value="1" if self.value == "1"
		elsif header.code =="date"
			value=self.date.to_s(:dmy) if self.date

		else
			value=self.value
		end
	
		return value
	end
end
