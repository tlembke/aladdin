class Paragraph < ActiveRecord::Base
	belongs_to :chapter

	def updateMessage
		if self.updated_at.to_date == Date.today
			message = "Updated today"
		else
			message = "Updated on " + self.updated_at.strftime("%d/%m/%Y")
		end
		return message
	end
end
