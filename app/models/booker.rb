class Booker < ActiveRecord::Base
	belongs_to :clinic

	# a booker with no clinic is on the waiting list
	# a booker on the waiting list booker.genie = x a current patient
	# a booker on the waiting list booker.genie = "" new patient

	def age
		age=0
		if self.dob
			age = ((Time.zone.now - self.dob.to_time) / 1.year.seconds).floor
		end
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

     def self.add_to_waiting(genie,surname,firstname,dob,email,mobile,vaxtype,eligibility)
		    @booker = Booker.new
		    @booker.surname = surname
		    @booker.firstname = firstname
		    @booker.dob = dob
		    @booker.clinic_id = 0
		    @booker.genie = genie
		    @booker.vaxtype = vaxtype
		    @booker.eligibility = eligibility
		    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
			@booker.mobile = crypt.encrypt_and_sign(mobile)
			@booker.email = crypt.encrypt_and_sign(email)
			@booker.save
			return @booker

 	end   
end
