module ClinicsHelper
	def showBooked(genie)
		returnText = "<br>"
		bookings=Booker.where(genie: genie).all
		if bookings.count > 0
			   returnText = "<ul>"
				bookings.each do |booking|
						returnText = returnText + "<li>" + booking.vaxtype + " " + booking.clinic.clinicdate.strftime("%A, %B %d") + "</li>"
				end
				returnText = returnText + "</ul>"



		end
		return returnText.html_safe

	end
end
