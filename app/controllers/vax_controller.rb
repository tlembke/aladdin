class VaxController < ApplicationController
  skip_before_filter :require_login
  def index
  		@noDays=3
  		@noGroups=3
  		@theText = "Hello, let's see if we can book you a vaccination"
      clinicTemplate=Clinic.where(vaxtype: "Covax", template: true).first
      @covaxAge = clinicTemplate.age



  end

  def book
  end



  def nextMessage
  		@thePatient =[]
  		@theText = ""
  		case params[:message]
  		when "findpatient"
  			@vaxtype=params[:vaxtype]
  			@theText = "I'll need a few details for your " + @vaxtype.upcase + " booking"
  			@thePartial = "form"
      when "unbook"
        @vaxtype=params[:vaxtype]
        @booker=Booker.find(params[:booker])
        @theText = "I have unbooked you for " + @booker.clinic.clinicdate.strftime("%d/%m/%Y") + "<p>You can book another appointment below"
        @theText=@theText.html_safe
        @thePatient=checkPatient(@vaxtype,@booker.surname,@booker.firstname,@booker.dob)
        @booker.destroy
        @thePartial = "confirmPatient"


  		when "checkpatient"
  			
  			@vaxtype=params[:vaxtype]
  			
  			unless params[:vaxtype].blank? or params[:surname].blank? or params[:date].blank?
       
	  		
	  			@dob = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
	  		
	  			@thePatient = checkPatient(@vaxtype,params[:surname],params[:firstname],@dob)
	  			if @thePatient == "0" or @thePatient =="3"
	  				@theText = "Hmm. That's strange."
	  				@thePartial = "form"
	  			else
              @theText = @patient['KNOWNAS']=="" ? @patient['FIRSTNAME'] : @patient['KNOWNAS']
              @theText = "Thanks, " + @theText
              @theText += ". We have found you in our records."
            # Does this person already have a booking?
            @booker=Booker.where(genie: @thePatient['ID'],vaxtype: @vaxtype).first

            if @booker
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
                            age = ((Time.zone.now - @patient.dob.to_time) / 1.year.seconds).floor
                            clinicTemplate=Clinic.where(vaxtype: @booker.vaxtype, template: true).first
                            @booker.eligibility=1
                            if age<clinicTemplate.age
                              @booker.eligibility=2
                            end
		                        @booker.save
		                        @thePatient = @patient
		                        @vaxtype = @clinic.vaxtype


                      

		                        @theText = "Good news. You are booked in for " + @booker.vaxtype + " on " + @clinic.clinicdate.strftime("%A, %B %d")+ " at " + timeFormat(@booker.bookhour,@booker.bookminute)
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
                        PatientMailer.clinic_booked(@booker,@patient.email).deliver_now
                      end

		                 end

             end

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
		              surname_text= "Surname = '%s'" % surname
		          end
		          firstname_text=""
                  if firstname and firstname!=""
                       firstname = firstname + "%"
                      firstname_text="(FirstName LIKE '%s'" % firstname
                      firstname_text=firstname_text + " OR KnownAs LIKE '%s'" % firstname
                      firstname_text+=")"
                  end
                  if surname_text!="" and firstname_text!=""
                    surname_text=surname_text + " AND " + firstname_text
                  end
		   
		          dob_text= " AND DOB = '" + dob.strftime("%Y-%m-%d") +"'"

		          # sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, MedicareNum, MedicareRefNum, IHI, HomePhone, MobilePhone,  CultureCode, EmailAddress,  PTCL_Id_Fk FROM Patient WHERE id = "+patient       


		          where_clause = surname_text + dob_text

                  sql = "SELECT Id, Surname,FirstName, KnownAs, EmailAddress, MobilePhone, Ethnicity FROM Patient WHERE " + where_clause
            
                  puts sql


                  sth = dbh.run(sql)
             
                  @patients_search=[]
                  sth.fetch_hash do |row|
                    #patient_h = Hash["Surname" => row[0], "FirstName" => row[1],"id"=>row[3]]
                    @patients_search<< row
                  end
                  sth.drop
                  dbh.disconnect
                  if @patients_search.length==0
                  	 @patient = "0"
                  	 flash.now[:notice] = "We couldn’t find a patient with Surname " + surname.upcase + " and First Name " + firstname[0...-1].upcase + " with Date of Birth " + dob.strftime("%d/%m/%Y") + ". Please check and try again or give us a ring on 02 66280505"
    				 
                  elsif @patients_search.length>1
                  		
                  		flash.now[:notice] = "Who would have thunk it. We have two patients with that surname and first name and date of birth. Please try again or give us a ring on 02 66280505"
    					@patient = "2"
    					
    					
    			 else
               # OK, so all good and we have one patient
    			 		@patient = @patients_search[0]

              criteriaMessage=""
              criteriaBoxes=[]
              eligible = false


              # check eligibility
              # age

              age = ((Time.zone.now - dob.to_time) / 1.year.seconds).floor

              # get criteria for vaxtype
              clinicTemplate=Clinic.where(vaxtype: vaxtype, template: true).first

              

              if age < 18
                 criteriaMessage = "You need to be over 18 to book online. Please ring us"
              elsif age > clinicTemplate.age
                  eligible = true
              elsif age > clinicTemplate.ATSIage and @patient['ETHNICITY']== "Indigenous"
                  eligible = true
              end

              if age > 18 and eligible == false
                  if clinicTemplate.healthcare and clinicTemplate.chronic
                      criteriaMessage="You need to have either a designated health condition <a href ='#designated-conditions-modal' onClick=\"$('#designated-conditions-modal').modal('show');\">(click to show)</a> or be a health care worker to book using this form"
                      criteriaBoxes=[1,2]
                  elsif clinicTemplate.healthcare
                      criteriaMessage="You need to be a health care worker to book using this form"
                      criteriaBoxes=[1]        
                  elsif clinicTemplate.chronic
                      criteriaMessage="You need to have a one of these conditions <a href ='#designated-conditions-modal' onClick=\"$('#designated-conditions-modal').modal('show');\">(click to show)</a> to book using this form"
                      criteriaBoxes=[2]  
                  end
                    
              end
      
              @patient['CRITERIAMESSAGE'] = criteriaMessage
              @patient['CRITERIABOXES'] = criteriaBoxes
              @patient['ELIGIBLE'] = eligible





    			 end

    			            
            
            
            	

		             			
		                  
            else
            	@patient = "3"  
            	flash[:notice] = "Sorry, we can't search right now. Give us a ring on 02 66280505"
                

            end
            return @patient





 		end
          def sendemail
                  PatientMailer.test_email.deliver_later
          end
end
