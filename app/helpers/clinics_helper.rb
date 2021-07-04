module ClinicsHelper
	def showBooked(genie)
		returnText = "<br>"
		bookings=Booker.where(genie: genie).all
		if bookings.count > 0
			   returnText = "<ul>"
				bookings.each do |booking|

						if booking.clinic_id == 0
							returnText = returnText + "<li>" + booking.vaxtype + " - Waiting List</li>"
						else
							returnText = returnText + "<li>" + booking.vaxtype + " " + booking.dose.to_s + " " + booking.clinic.clinicdate.strftime("%A, %B %d") + "</li>"
						end
				end
				returnText = returnText + "</ul>"



		end
		return returnText.html_safe

	end
end
