class Booker < ActiveRecord::Base
	belongs_to :clinic

	def age
		age = ((Time.zone.now - self.dob.to_time) / 1.year.seconds).floor
	end

	def nextDate
		      nextDate = nil
		      if nextBooker=Booker.where(dose: 2, genie: self.genie).first
		          nextDate = nextBooker.clinic.clinicdate
		      end
		    return nextDate
    end
    def nextDateTime
		      nextDate = nil
		      if nextBooker=Booker.where(dose: 2, genie: self.genie).first
		          nextDate = nextBooker.clinic.clinicdate.strftime("%d/%m/%y")
		          theTime =nextBooker.bookhour.to_s + ":" + nextBooker.bookminute.to_s.rjust(2, '0')
        		  nextBooker.bookhour.to_i < 12 ? theTime += "am" : theTime +="pm"
        		  nextDate = nextDate + " " + theTime

		      end
		    return nextDate
    end

    def patient
    	return Patient.getPatientMini(self.genie)
    end

    def emaildec
    	email = ""
    	unless self.email.blank?
    		crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
			email = crypt.decrypt_and_verify(self.email)
		end
		return email
    end
    def mobiledec
    	mobile = ""
    	unless self.mobile.blank?
	    	crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
			mobile = crypt.decrypt_and_verify(self.mobile)
		end
		return mobile
    end    
end
