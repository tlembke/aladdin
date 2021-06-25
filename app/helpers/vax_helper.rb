module VaxHelper
	def fullVaxtype(vaxtype)
		case vaxtype 
			when "Fluvax"
				returnText = "Influenza Vacciation"
			when "Covax"
				returnText = "Covid vaccination (AstraZeneca)"
			when "CovaxP"
				returnText = "Covid vaccination (Pfizer)"
			end
		end
end
