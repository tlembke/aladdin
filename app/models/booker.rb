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

     def self.add_to_waiting(genie,surname,firstname,dob,email,mobile,vaxtype,eligibility,priority)
		    @booker = Booker.new
		    @booker.surname = surname
		    @booker.firstname = firstname
		    @booker.dob = dob
		    @booker.clinic_id = 0
		    @booker.genie = genie
		    @booker.vaxtype = vaxtype
		    @booker.priority = priority
		    @booker.eligibility = eligibility
		    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
			@booker.mobile = crypt.encrypt_and_sign(mobile)
			@booker.email = crypt.encrypt_and_sign(email)
			@booker.save
			return @booker

 	end  

 	def self.waiting
 		 vaxtypes =["Fluvax","Covax","CovaxP"]
 		 waitingArray=Array.new
 		 vaxtypes.each do | vaxtype |
 		 	puts vaxtype
 		 	waitingArray << Booker.getCounts(vaxtype)
 		 end 
 		 return waitingArray


 	end

 	def self.getCounts(vaxtype)

 	     newWaiting = Booker.where(clinic_id: 0, vaxtype: vaxtype, genie: 0).count
 		 oldWaiting = Booker.where(clinic_id: 0,vaxtype: vaxtype).where.not(genie: 0).count
 		 newInvited = Booker.where(clinic_id: 0, genie: 0,vaxtype: vaxtype,invite: true).count
 		 oldInvited = Booker.where(clinic_id: 0,invite: true,vaxtype: vaxtype).where.not(genie: 0).count
 		 return [vaxtype,oldWaiting,oldInvited, newWaiting, newInvited]
  end

  def priorityText
  		returnText = ""
  		case self.priority
  			when 1
  				returnText = "HCW"
  			when 2		
  				returnText = "ACW"
  			when 3
  				returnText = "MW"
  			when 4
  				returnText = "Dis"
  		end
  		return returnText
  end

  def vaxGiven?(dbh)
  	# get vaccination Hx for patient with this booking

       	  vaxGiven=false
       	  self.vaxtype == "Covax"? acircode = "COVAST" : acircode = "COMIRN"
		  immunisations= get_immunisation(self.genie,acircode,dbh)
	      immunisations.each do |jab|

	              if jab['GIVENDATE'] == self.clinic.clinicdate
	                  vaxGiven = true
	              end

	      end


 
		  return vaxGiven

  end

    def vaxDates(dbh)
  	# get vaccination Hx for patient with this booking
  	# not used
	  	  vaxDates=Hash.new

		  immunisations= get_immunisations(self.genie,dbh)
	      vaxDates['COVAST']=[]
	      vaxDates['COMIRN']=[]
	      immunisations.each do |jab|
	          if jab['ACIRCODE']=="COVAST"
	              vaxDates['COVAST'] << jab['GIVENDATE']
	          end
	          if jab['ACIRCODE']=="COMIRN"
	              vaxDates['COMIRN'] << jab['GIVENDATE']
	          end
	      end


	         
	      return vaxDates

    end

      def get_immunisation(patient,acircode,dbh)
          sql = "SELECT ACIRCode, GivenDate, Vaccine FROM Vaccination WHERE PT_Id_FK = " + patient.to_s + " AND ACIRCode = '" + acircode + "' ORDER BY GivenDate DESC"
          puts sql
         

          sth = dbh.run(sql)
               
          immunisations=[]
          sth.fetch_hash do |row|

            immunisations << row
          end

         

         
          sth.drop
          return immunisations

    end

end
