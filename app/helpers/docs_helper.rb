module DocsHelper
	def showCat(doccat)
		
		if doccat == nil
			doccat = 0
		end
		catarray=["","Handout", "Form", "Resource","Policy"]

		doccat > 0 ? returnText = catarray[doccat] : returnText =""
		return returnText
	end


end
