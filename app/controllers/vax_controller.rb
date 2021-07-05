class VaxController < ApplicationController
  skip_before_filter :require_login
  def index

        @vaxtype= params[:vaxtype]

  		@noDays=3
  		@noGroups=3
  		@theText = "Hello, let's see if we can book you a vaccination.<p>"
      if @vaxtype == "Fluvax" or @vaxtype == "Covax"
        @theText = @theText + "Please click on the orange button below"
      else
        @theText = @theText + "Please click on one of the orange buttons below"
      end
      @theText=@theText.html_safe
      @clinicTemplate=Clinic.where(vaxtype: "Covax", template: true).first
      @covaxAge = @clinicTemplate.age
      @clinicPTemplate=Clinic.where(vaxtype: "CovaxP", template: true).first
      @covaxPAge = @clinicPTemplate.age



  end

  def book
  end



  def nextMessage
      clinicTemplate=Clinic.where(vaxtype: "Covax", template: true).first
      @covaxAge = clinicTemplate.age
      clinicPTemplate=Clinic.where(vaxtype: "CovaxP", template: true).first
      @covaxPAge = clinicTemplate.age
  		@thePatient =[]
  		@theText = ""
  		case params[:message]
      when 'waitinglist'
        @vaxtype=params[:vaxtype]
        @dob = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
        if @vaxtype.start_with? "Covax"
            age = ((Time.zone.now - @dob.to_time) / 1.year.seconds).floor
            if age < @covaxAge 
                @vaxtype="CovaxP"
            end
            eligibility=1
            if age < @covaxPAge 
                eligibility = 2
            end
        end
        @booker=Booker.add_to_waiting(0,params[:surname],params[:firstname],@dob,params[:email],params[:mobile],@vaxtype,eligibility)
        @patient = getPatientFromBooker(@booker.id)
        @booker_id=@booker.id
        @thePartial = "confirmPatient"
        @theText="Thanks " + params[:firstname].to_s + ". We have added you to our records"
  		when "findpatient"
  			@vaxtype=params[:vaxtype]
  			@theText = "I'll need a few details for your " + @vaxtype.upcase + " booking"
  			@thePartial = "form"
      when "unbook"
        @vaxtype=params[:vaxtype]
        @booker=Booker.find(params[:booker])
        @theText = "I have unbooked you for " + @booker.clinic.clinicdate.strftime("%d/%m/%Y") + "<p>You can book another appointment below"
        @theText=@theText.html_safe
        #@thePatient=checkPatient(@vaxtype,@booker.surname,@booker.firstname,@booker.dob)
        
        @patient = getPatientFromBooker(@booker.id)
        
        @booker_id=@booker.id
        debugger
        if @booker.genie == 0
          @booker.clinic_id = 0
           
        else
             @booker.destroy
        end
        
        @thePartial = "confirmPatient"



  		when "checkpatient"
  			@vaxtype=params[:vaxtype]
  			
  			unless params[:vaxtype].blank? or params[:surname].blank? or params[:date].blank?
            
      	  		
      	  			@dob = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)

                @patient = checkPatient(@vaxtype,params[:surname],params[:firstname],@dob)
                      
                      
                if @patient == "0"
                  # not an old patient.
                  # perhaps a new patient who has a booking with genie_id = 0
                        searchfirstname = params[:firstname][0..2] + "%"
                         searchvaxtype= @vaxtype
                         if @vaxtype.start_with? "Covax"
                            searchvaxtype = "Covax%"
                         end

                        if @booker = Booker.where('genie = 0 and surname = ? and firstname LIKE ? and vaxtype LIKE ? and dob = ?', params[:surname],searchfirstname,searchvaxtype,@dob).first
                #on waiting list
                                # this is a patient on the waiting list
                             

                                      @theText = "Thanks, " + @booker.firstname

                                      @theText += ". We have found you in our records."
                                      @patient = getPatientFromBooker(@booker.id)

                                      @booker_id = @booker.id



                                      if @booker.clinic_id and @booker.clinic_id != 0
                                          @thePartial = "alreadyBooked"
                                          @clinic = @booker.clinic
                                      else
                                        @thePartial = "confirmPatient"
                                      end

    
                          
                        else

                                @theText = "Hmm. We couldn’t find you in our records."
                                @patient=Hash.new
                                @patient['SURNAME'] = params[:surname]
                                @patient['FIRSTNAME']= params[:firstname]
                                @patient['DOB']= @dob
                                @thePartial = "wait"
                        end
                elsif @patient=="3"
                    @theText ="Hmm. We can't search right now. Please try again later or ing us on 02 66280505"
                    @thePartial ="form"
                  else
                  # checkPatient() will change vaxtype depending on patient eligibility
                    # to add - see if this patient also has a booking as a new patient


                    # patient has been found.
                    @vaxtype=@patient['VAXTYPE']
                    @theText = @patient['KNOWNAS']=="" ? @patient['FIRSTNAME'] : @patient['KNOWNAS']
                    @theText = "Thanks, " + @theText
                    @theText += ". We have found you in our records."
                 
                     @booker=Booker.joins(:clinic).where("bookers.genie = ? and bookers.vaxtype = ? and clinics.clinicdate > ? ",@patient['ID'],@vaxtype, Date.today).first
                
                    if  @patient['COVAST'].length + @patient['COMIRN'].length >=2

                                  @theText = "Your COVID19 Vaccination is complete"
                                  flash.now[:notice] = "You have immunity!"
                                  @thePartial = "complete"
                    elsif @booker
                      @thePartial = "alreadyBooked"
                      @clinic = @booker.clinic
                    else
                      @theText = @patient['KNOWNAS']=="" ? @patient['FIRSTNAME'] : @patient['KNOWNAS']
                      @theText = "Thanks, " + @theText

                      @theText += ". We have found you in our records."
                      @thePartial = "confirmPatient"

                    end
                end

	  		else
      	  			@theText = "We need a Surname and a DOB to search"
      	  			flash.now[:notice] = "We need a Surname and a DOB to book an appointment"
      	  			@thePartial = "form"
	  		end
          
	  	when "bookpatient"
	  		if params[:patient] and params[:clinic] and params[:starthour] and params[:startminute]

             if params[:booker] != 0
                    # do the new patient stuff
                    # repeats what follow so should be fixed to be DRY 
                    @booker=Booker.find(params[:booker])
                    @clinic=Clinic.find(params[:clinic])
                    @booker.bookhour = params[:starthour]
                    @booker.bookminute = params[:startminute]
                    @booker.vaxtype = @clinic.vaxtype
                    @booker.clinic_id = @clinic.id
                    @booker.dose=1
                    @booker.contactby=2
                    @booker.save
                    @thePatient=Hash.new
                    @thePatient["SURNAME"] = @booker.surname
                    @thePatient["FIRSTNAME"] = @booker.firstname
                    @thePatient["FULLNAME"] = @booker.firstname + " " + @booker.surname
                    @vaxtype = @clinic.vaxtype
                    theMess=""
                                              # if it is a paired appointment, also book for that
                    if @clinic.pair1 != nil and @booker.dose !=2
                          #what would the first available starttime be
                          nextAppt = Clinic.findTime(@clinic.pair1)
                          useClinic=@clinic.pair1
                          if nextAppt==nil and @clinic.pair2 !=nil
                             useClinic=@clinic.pair2
                            nextAppt=Clinic.findTime(@clinic.pair2)
                          end
                     
                          if nextAppt
                       
                              
                              @booker2=@booker.dup
                              @booker2.clinic_id = useClinic
                              @booker2.dose=2
                              @booker2.bookhour = nextAppt[0]
                              @booker2.bookminute = nextAppt[1]
                              @booker2.save
                              theMess = "<p>You are also booked in for your second vaccination on "+  @booker2.clinic.clinicdate.strftime("%A, %B %d")+ " at " + timeFormat(@booker2.bookhour,@booker2.bookminute)+ "."
                           end

                    end
                   clinicName = @vaxtype
                    if clinicName == "Covax"
                        clinicName = "Covid 19 Vaccination (Astra Zeneca)"
                    elsif clinicName == "CovaxP"  
                        clinicName = "Covid 19 Vaccination (Pfizer)"
                    end
                    @theText = "Good news. You are booked in for " + clinicName + " on " + @clinic.clinicdate.strftime("%A, %B %d")+ " at " + timeFormat(@booker.bookhour,@booker.bookminute) + theMess.html_safe
                    if @vaxtype =="Covax"

                      @theText = @theText + "<p>Don't forget to bring your consent form"
                      if @booker.eligibility > 1
                        @theText = @theText + " and your Proof of Eligibility Form"
                      end
                    end
                    @theText = @theText.html_safe
                    @thePartial = "booked"
                    @email = @booker.mobiledec

                    unless @email.blank?
                        booker2_id = 0
                        if @booker2
                            booker2_id=@booker2.id
                        end
                        PatientMailer.clinic_booked(@booker.id,booker2_id,@email).deliver_later
                    end



             else

            			@username = Pref.aladdinuser
            			@password = Pref.decrypt_password(Pref.aladdinpassword)
           				 @id=session[:id]
            			@name=session[:name]

            			connect_array=connect(@username,@password)
            			@error_code=connect_array[1]
           
            			if (@error_code==0)
                   				dbh=connect_array[0]
                   				@clinic=Clinic.find(params[:clinic])
			  			            @booker=Booker.new
	                        @booker.genie = params[:patient]
	                        @booker.bookhour = params[:starthour]
	                        @booker.bookminute = params[:startminute]
	                        @patient = Patient.get_patient(params[:patient],dbh)
	                        @booker.surname = @patient.surname
	                        @booker.firstname =@patient.firstname
	                        @booker.dob = @patient.dob
	                        @booker.vaxtype = @clinic.vaxtype
	                        @booker.clinic_id = @clinic.id

                          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
                          @booker.email = crypt.encrypt_and_sign(@patient.email)
                          @booker.mobile = crypt.encrypt_and_sign(@patient.mobilephone)
                        
                          age = ((Time.zone.now - @patient.dob.to_time) / 1.year.seconds).floor
                          clinicTemplate=Clinic.where(vaxtype: @booker.vaxtype, template: true).first
                          @booker.eligibility=1
                          if age<clinicTemplate.age
                            @booker.eligibility=2
                          end
                          @booker.dose=1
                          if params[:dose] ==2
                              @booker.dose=2
                          end
                          @booker.contactby=2
	                        @booker.save
	                        @thePatient = @patient
	                        @vaxtype = @clinic.vaxtype
                          theMess=""
                          # if it is a paired appointment, also book for that
                          if @clinic.pair1 != nil and @booker.dose !=2
                                #what would the first available starttime be
                                nextAppt = Clinic.findTime(@clinic.pair1)
                                useClinic=@clinic.pair1
                                if nextAppt==nil and @clinic.pair2 !=nil
                                   useClinic=@clinic.pair2
                                  nextAppt=Clinic.findTime(@clinic.pair2)
                                end
                           
                                if nextAppt
                             
                                    
                                    @booker2=@booker.dup
                                    @booker2.clinic_id = useClinic
                                    @booker2.dose=2
                                    @booker2.bookhour = nextAppt[0]
                                    @booker2.bookminute = nextAppt[1]
                                    @booker2.save
                                    theMess = "<p>You are also booked in for your second vaccination on "+  @booker2.clinic.clinicdate.strftime("%A, %B %d")+ " at " + timeFormat(@booker2.bookhour,@booker2.bookminute)+ "."
                                 end

                          end



                      
                          clinicName = @vaxtype
                          if clinicName == "Covax"
                              clinicName = "Covid 19 Vaccination (Astra Zeneca)"
                          elsif clinicName == "CovaxP"  
                              clinicName = "Covid 19 Vaccination (Pfizer)"
                          end
	                        @theText = "Good news. You are booked in for " + clinicName + " on " + @clinic.clinicdate.strftime("%A, %B %d")+ " at " + timeFormat(@booker.bookhour,@booker.bookminute) + theMess.html_safe
	                        if @vaxtype =="Covax"

	                        	@theText = @theText + "<p>Don't forget to bring your consent form"
                            if @booker.eligibility > 1
                              @theText = @theText + " and your Proof of Eligibility Form"
                            end
	                        end
	                        @theText = @theText.html_safe
                					@thePartial = "booked"
                					dbh.disconnect

                          unless @patient.email.blank?
                              booker2_id = 0
                              if @booker2
                                  booker2_id=@booker2.id
                              end
                              PatientMailer.clinic_booked(@booker.id,booker2_id,@patient.email).deliver_later
                          end
                        
                  end #end error code

             end #end if booker_id
          end # if params

  		else
  			@theText ="This is the next message. Boring hey"
  			@thePartial = "theText"
  		end


	

  end


     def timeFormat(thehour,theminute)

            theTime =thehour.to_s + ":" + theminute.to_s.rjust(2, '0')
            thehour < 12 ? theTime += "am" : theTime +="pm"
            return theTime
     end




   def checkPatient(vaxtype,surname,firstname,dob)
   		


            @username = Pref.aladdinuser
            @password = Pref.decrypt_password(Pref.aladdinpassword)



           
			connect_array=connect(@username,@password)
			@error_code=connect_array[1]

			if (@error_code==0)
       			   dbh=connect_array[0]
            
                        






		          # Search 
		          @patients_search=[]
		      
		          surname_text=""
		          if surname and surname !=""
		            surname = surname.sub("'"){"''"}
                 surname=surname.strip
		              surname_text= "Surname = '%s'" % surname
		          end
		          firstname_text=""
                  if firstname and firstname!=""
                       firstname = firstname[0..2] + "%"
                      firstname_text="(FirstName LIKE '%s'" % firstname
                      firstname_text=firstname_text + " OR KnownAs LIKE '%s'" % firstname
                      firstname_text+=")"
                  end
                  if surname_text!="" and firstname_text!=""
                    surname_text=surname_text + " AND " + firstname_text
                  end
		   
		          dob_text= " AND DOB = '" + dob.strftime("%Y-%m-%d") +"'"

		          # sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, MedicareNum, MedicareRefNum, IHI, HomePhone, MobilePhone,  CultureCode, EmailAddress,  PTCL_Id_Fk FROM Patient WHERE id = "+patient       


		          where_clause = surname_text + dob_text + " AND Deceased = false"

                  sql = "SELECT Id, Surname,FirstName, KnownAs, EmailAddress, MobilePhone, Ethnicity FROM Patient WHERE " + where_clause
            
                  puts sql


                  sth = dbh.run(sql)
             
                  @patients_search=[]
                  sth.fetch_hash do |row|
                    #patient_h = Hash["Surname" => row[0], "FirstName" => row[1],"id"=>row[3]]
                    @patients_search<< row
                  end
                  sth.drop

                  # get immunisation history for patient

                 

                 
                  if @patients_search.length==0
                  	 @patient = "0"
                  	 #flash.now[:notice] = "We couldn’t find a patient with Surname " + surname.upcase + " and First Name " + firstname.upcase + " with Date of Birth " + dob.strftime("%d/%m/%Y")
    				 
                  elsif @patients_search.length>1
                  		
                  		flash.now[:notice] = "Who would have thunk it. We have two patients with that surname and first name and date of birth. Please try again or give us a ring on 02 66280505"
    					         @patient = "2"
    					
    					
    			 else
               # OK, so all good and we have one patient
    			 		@patient = @patients_search[0]
              @booker_id=0

              criteriaMessage=""
              criteriaBoxes=[]
              eligible = false


              # check eligibility
              # age

              age = ((Time.zone.now - dob.to_time) / 1.year.seconds).floor
              @patient['AGE'] = age
              eligibilityarray=getEligibility(age,vaxtype)
              @patient['CRITERIAMESSAGE'] = eligibilityarray[0]
              @patient['CRITERIABOXES'] = eligibilityarray[1]
              @patient['ELIGIBLE'] = eligibilityarray[2]
 

              # get criteria for vaxtype
    


              # has the patient had an immunsiation
              immunisations= get_immunisations(@patient["ID"],dbh)
              @patient['COVAST']=[]
              @patient['COMIRN']=[]
              immunisations.each do |jab|
                  if jab['ACIRCODE']=="COVAST"
                      @patient['COVAST'] << jab['GIVENDATE']
                  end
                  if jab['ACIRCODE']=="COMIRN"
                      @patient['COMIRN'] << jab['GIVENDATE']
                  end
              end

              clinicTemplateAZ = Clinic.where(vaxtype: "Covax", template: true).first
              @patient['VAXTYPE'] = "Covax"
              if age < clinicTemplateAZ.age and @patient['COVAST'].length == 0
                 @patient['VAXTYPE']="CovaxP"
              end







    			 end

    			            
            
            
            	

		             			
		                  
            else
            	@patient = "3"  
            	flash[:notice] = "Sorry, we can't search right now. Give us a ring on 02 66280505"
                

            end
             dbh.disconnect
            return @patient





 		end

    def createPatientArray(surname,firstname,dob)
    age = ((Time.zone.now - dob.to_time) / 1.year.seconds).floor
    age = ((Time.zone.now - dob.to_time) / 1.year.seconds).floor

    end


    def  getEligibility(age,vaxtype)
    # get criteria for vaxtype
              if vaxtype=="Fluvax"
                clinicTemplate=Clinic.where(vaxtype: vaxtype, template: true).first
              else
                clinicTemplate=Clinic.where(vaxtype: "CovaxP", template: true).first
                clinicTemplateAZ = Clinic.where(vaxtype: "Covax", template: true).first
              end



              

              if age < 18
                 criteriaMessage = "You need to be over 18 to book online. Please ring us"
              elsif age >= clinicTemplate.age
                  eligible = true
              elsif clinicTemplate.ATSIage and clinicTemplate.ATSIage>0 and age >= clinicTemplate.ATSIage and @patient['ETHNICITY']== "Indigenous"
                  eligible = true
              end

              if age > 18 and eligible == false
                  if clinicTemplate.healthcare and clinicTemplate.chronic
                      criteriaMessage="You need to have either a designated health condition or be a health care worker to book using this form"
                      criteriaBoxes=[1,2]
                  elsif clinicTemplate.healthcare
                      criteriaMessage="You need to be a health care worker to book using this form"
                      criteriaBoxes=[1]        
                  elsif clinicTemplate.chronic
                      criteriaMessage="You need to have a designated health conditions to book using this form"
                      criteriaBoxes=[2]  
                  else
                      criteriaMessage="It appears you are not yet eligible to receive a vaccine. We have vaccination available for people aged over " + clinicTemplate.age.to_s  + ". Please contact us on 02 66280505 if this is incorrect"
                  end
                    
              end

     

              return [criteriaMessage,criteriaBoxes,eligible]
      end

      def getPatientFromBooker(booker_id)
          @booker=Booker.find(booker_id)
          @patient=Hash.new
          @patient['SURNAME'] = @booker.surname
          @patient['FIRSTNAME'] = @booker.firstname
          age = ((Time.zone.now - @booker.dob.to_time) / 1.year.seconds).floor
          @patient['AGE'] = age
          eligibilityarray=getEligibility(age,@vaxtype)
          @patient['CRITERIAMESSAGE'] = eligibilityarray[0]
          @patient['CRITERIABOXES'] = eligibilityarray[1]
          @patient['ELIGIBLE'] = eligibilityarray[2]
          @patient['VAXTYPE'] = eligibilityarray[3]
          @patient['ID'] = 0

          @patient['COVAST']=[]
          @patient['COMIRN']=[]

          clinicTemplateAZ = Clinic.where(vaxtype: "Covax", template: true).first

          @patient['VAXTYPE'] = "Covax"
          if age < clinicTemplateAZ.age and @patient['COVAST'].length == 0
                  @patient['VAXTYPE']="CovaxP"
          end
          @vaxtype = @patient['VAXTYPE']
          @patient["STATUS"] = "New"
          @patient["INVITE"] = @booker.invite

          return @patient

      end

      def sendemail
              PatientMailer.test_email.deliver_later
      end
end
