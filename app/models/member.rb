class Member < ActiveRecord::Base
	belongs_to :patient

 def recall
      recall = Recall.find(self.genie_id)

      return recall

  end

  def showTitle
		theText = self.recall.title
		if theText == "Custom"
			unless self.note.blank?
				theText = self.note 
			end
			# make editable
			theText = "<a href='#' data-type='text' data-url='members/" + self.id.to_s + "'  data-resource='member' data-name='note' class='editable'>" + theText + "</a>"
		end
		return theText.html_safe
	end

  




end
