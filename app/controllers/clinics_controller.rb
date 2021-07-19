class ClinicsController < ApplicationController
  before_action :set_clinic, only: [:show, :edit, :update, :destroy, :book, :email, :sms, :audit]

  # GET /clinics
  # GET /clinics.json
  def index

      # temp fix
      @orphans = Booker.where(dose: nil, vaxtype: "Covax").all
      @orphans.update_all(dose: 1)



        # are there already templates?
        # if not make them using default values
       if  @fluvaxtemplate = Clinic.where(vaxtype: "Fluvax",template: true).first
            @fluvaxtemplateID = @fluvaxtemplate.id
       else
              @clinic = Clinic.new(vaxtype: "Fluvax", template: true)
              @clinic.save
              @fluvaxtemplateID = @clinic.id
              @fluvaxtemplate= @clinic
        end

        if @covaxtemplate = Clinic.where(vaxtype: "Covax",template: true).first
            @covaxtemplateID = @covaxtemplate.id
        else
              @clinic = Clinic.new(vaxtype: "Covax", template: true)
              @clinic.pairpref=12
              @clinic.pairmax=16
              @clinic.pairmin=4
              @clinic.save
              @covaxtemplate = @clinic
        end
        if @covaxPtemplate = Clinic.where(vaxtype: "CovaxP",template: true).first
            @covaxPtemplateID = @covaxPtemplate.id
        else
              @clinic = Clinic.new(vaxtype: "CovaxP", template: true)
              @clinic.pairpref=3
              @clinic.pairmax=6
              @clinic.pairmin=3
              @clinic.save
              @covaxPtemplate = @clinic
              @covaxPtemplateID = @clinic.id
        end
        #chnaging so only options are "Covax" and "Fluvax"
        params[:vaxtype]== "Fluvax" ? @vaxtype = "Fluvax" : @vaxtype = "Covax"


        if @vaxtype.start_with? "Covax"
            @clinics = Clinic.where("template == false and vaxtype LIKE 'Covax%'")
        elsif @vaxtype == "Fluvax"
            @clinics = Clinic.where(vaxtype: "Fluvax",template: false)
        else
            @clinics = Clinic.where(template: false)
        end



  end

    def admin

        # are there already templates?
        # if not make them using default values
       if  @fluvaxtemplate = Clinic.where(vaxtype: "Fluvax",template: true).first
            @fluvaxtemplateID = @fluvaxtemplate.id
       else
              @clinic = Clinic.new(vaxtype: "Fluvax", template: true)
              @clinic.save
              @fluvaxtemplateID = @clinic.id
        end

        if @covaxtemplate = Clinic.where(vaxtype: "Covax",template: true).first
            @covaxtemplateID = @covaxtemplate.id
        else
              @clinic = Clinic.new(vaxtype: "Covax", template: true)
              @clinic.save
              @covaxtemplateID = @clinic.id
        end

        if @covaxPtemplate = Clinic.where(vaxtype: "CovaxP",template: true).first
            @covaxPtemplateID = @covaxPtemplate.id
        else
              @clinic = Clinic.new(vaxtype: "CovaxP", template: true)
              @clinic.save
              @covaxPtemplateID = @clinic.id
        end



        params[:vaxtype] ? @vaxtype = params[:vaxtype] : @vaxtype = "Fluvax"
        @showAll = params[:showAll]
        if @vaxtype.start_with? "Covax"

            if params[:showAll]

               @clinics = Clinic.where("vaxtype LIKE ? AND template = ?","Covax%",false).order(:clinicdate)
            else
              @clinics = Clinic.where("vaxtype LIKE ? AND template = ? and clinicdate >=?","Covax%",false,Date.today).order(:clinicdate)
            end
        elsif @vaxtype == "Fluvax"
            if params[:showAll]
               @clinics = Clinic.where(vaxtype: "Fluvax",template: false).order(:clinicdate)
            else         
              @clinics = Clinic.where("vaxtype = ? AND template = ? and clinicdate >=?","Fluvax",false,Date.today).order(:clinicdate)
            end
       
        else
            if params[:showAll]
                 @clinics = Clinic.where(template: false).order(:clinicdate)
            else
                 @clinics = Clinic.where("template = ? and clinicdate >=?", false, Date.today).order(:clinicdate)
            end
        end

  end

  # GET /clinics/1
  # GET /clinics/1.json
  def show
      params[:print] == "true" ? @print=true : @print=false
   
      if @print
          render :print
      end
  


  end

  # GET /clinics/new
  def new
    @vaxtype=params[:vaxtype]
    @clinic = Clinic.where(vaxtype: @vaxtype,template: true).first.dup
    @clinic.template = false
    
  end

  # GET /clinics/1/edit
  def edit

  end

  # POST /clinics
  # POST /clinics.json
  def create
    @clinic = Clinic.new(clinic_params)
    theMess=""
    respond_to do |format|
      if @clinic.save
        
        
        # Were was asked to create a pair in three months?
        if params[:makepair] and @clinic.vaxtype.start_with?("Covax")
            theMess = @clinic.makePair


        end


        format.html { redirect_to admin_clinics_url(vaxtype: @clinic.vaxtype), notice: 'Clinic was successfully created.' + theMess }
        format.json { render :show, status: :created, location: @clinic }
      else
        format.html { render :new }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clinics/1
  # PATCH/PUT /clinics/1.json
  def update
    theMess=""
    respond_to do |format|
      if @clinic.update(clinic_params)
        if params[:makepair] and @clinic.vaxtype.start_with?("Covax")
          theMess = @clinic.makePair
        end
        format.html { redirect_to admin_clinics_url(vaxtype: @clinic.vaxtype), notice: 'Clinic was successfully updated.' + theMess}
        format.json { render :show, status: :ok, location: @clinic }
      else
        format.html { render :edit }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clinics/1
  # DELETE /clinics/1.json
  def destroy
    @bookers=Booker.where(clinic_id: @clinic.id).all
    @vaxtype=@clinic.vaxtype
    if @bookers.count == 0
      # need to remove it as a pair
      Clinic.removePair(@clinic.id)
      @clinic.destroy
      @message = "Clinic was deleted"
    else
      @message = "Clinic has people booked and cannot be deleted"
    end
    
    respond_to do |format|
      format.html { redirect_to admin_clinics_path(vaxtype: @vaxtype), notice: @message }
      format.json { head :no_content }
    end
  end


 def book

      @bookhour=params[:hour]
      @bookminute=params[:minute]
      @genie=0
      if params[:genie]
        @genie= params[:genie]
      end

      if params[:genie] or params[:Surname]

            @username = session[:username]
            @password = session[:password]
            @id=session[:id]
            @name=session[:name]

            connect_array=connect()
            @error_code=connect_array[1]
            if (@error_code==0)
                   dbh=connect_array[0]
                   if params[:genie]
                        

                        @booker=Booker.new
                        @booker.genie = params[:genie]
                        @booker.bookhour = @bookhour
                        @booker.bookminute = @bookminute

                        @patient = Patient.get_patient(params[:genie],dbh)
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
                        @booker.contactby=1

                        @booker.dose=1
                        if @booker.vaxtype.start_with? "Covax"
                            if Booker.where(genie: @booker.genie,vaxtype: @booker.vaxtype,dose: 1).first or params[:dose] == "2"
                                  @booker.dose = 2
                            end
                        end
                        @booker.save
                        theMess=""
                        if @booker.vaxtype.start_with? "Covax"

                            
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
                                
                                    theMess = "Also booked in for a second vaccination on "+  @booker2.clinic.clinicdate.strftime("%A, %B %d")+ " at " + view_context.formatTime(@booker2.bookhour,@booker2.bookminute)+ "."
                                   
                                  end

                            end


                        end



                        # send email
                        booker2_id = 0
                        if @booker2
                          booker2_id=@booker2.id
                        end
                         unless @patient.email.blank?
                              PatientMailer.clinic_booked(@booker.id,booker2_id,@patient.email).deliver_later
                         end
                         # AgentTexter.alert(params).deliver
                        
                    elsif params[:Surname]




          # Search 
                      @patients_search=[]
                  
                      surname_text=""
                      if params[:Surname] and params[:Surname]!=""
                        surname = params[:Surname].sub("'"){"''"} + "%"
                          surname_text= "Surname LIKE '%s'" % surname
                      end
                      firstname_text=""
                      if params[:FirstName] and params[:FirstName]!=""
                           firstname = params[:FirstName] + "%"
                          firstname_text="(FirstName LIKE '%s'" % firstname
                          firstname_text=firstname_text + " OR KnownAs LIKE '%s'" % firstname
                          firstname_text+=")"
                      end
                      if surname_text!="" and firstname_text!=""
                        surname_text=surname_text + " AND "
                      end
                      where_clause = surname_text + firstname_text + " AND Deceased = false"
                      puts "Where is " + where_clause
                      if where_clause!=""
                              sql = "SELECT Surname,FirstName,LastSeenDate,id,DOB FROM Patient WHERE " + where_clause + " ORDER BY Surname, FirstName"
                              puts sql

                              sth = dbh.run(sql)
                         
                              @patients_search=[]
                              sth.fetch_hash do |row|
                                #patient_h = Hash["Surname" => row[0], "FirstName" => row[1],"id"=>row[3]]
                                @patients_search<< row
                              end
                              sth.drop
                      end
                    end
                  
                  dbh.disconnect

                
           else
                  flash[:alert] = "Unable to connect to database. "+get_odbc
                  flash[:notice] = connect_array[2]
                  redirect_to  controller: "genie", action: "login"
            end


    end

    respond_to do |format|
      format.html { 
        if @genie != 0
           redirect_to clinics_url(vaxtype: @booker.vaxtype),  notice: (@booker.firstname + " " + @booker.surname + " was booked in for " + @booker.vaxtype.upcase + @booker.dose.to_s + " on " + @clinic.clinicdate.strftime("%A, %B %d") + " at " + view_context.formatTime(@booker.bookhour,@booker.bookminute) + "." +  theMess).html_safe
        end
       }

    end



 








 end
 def unbook
      theMess =""
      @booker = Booker.find(params[:bookerID])
      genie=@booker.genie
      firstname=@booker.firstname
      surname = @booker.surname
      dob = @booker.dob
      if @booker.vaxtype.start_with? "Covax" and @booker.dose == 1
        if genie != 0
          if @booker2 = Booker.where(genie: genie, vaxtype: @booker.vaxtype, dose: 2).first
                theMess = " Covax2 on " + @booker2.clinic.clinicdate.strftime("%d-%m-%Y") + " was also unbooked"
                @booker2.destroy
          end
        else
           if @booker2 = Booker.where(firstname: firstname, surname: surname,  dob: dob,  vaxtype: @booker.vaxtype, dose: 2).first
                theMess = " Covax2 on " + @booker2.clinic.clinicdate.strftime("%d-%m-%Y") + " was also unbooked"
                @booker2.destroy
          end
        end
      end   
      


      @booker.destroy
      respond_to do |format|
      format.html { 
           redirect_to clinic_url, notice: @booker.firstname + " " + @booker.surname + " " + @booker.vaxtype + @booker.dose.to_s + " on " + @booker.clinic.clinicdate.strftime("%d-%m-%Y") + " was unbooked." + theMess
       }

    end

 end

 def checkvaxbooking
        @bookedresults=Booker.where("surname LIKE ?", params[:Surname]+"%").order(:Surname, :Firstname).all
        @vaxtype=params[:vaxtype]
 end

  def unbooksearch
      theMess =""
      @booker = Booker.find(params[:bookerID])
      @vaxtype=params[:vaxtype]
      firstname = @booker.firstname
      surname = @booker.surname
      genie=@booker.genie
      if @booker.vaxtype.start_with? "Covax" and @booker.dose == 1
        if genie != 0
          if @booker2 = Booker.where(genie: genie, vaxtype: @booker.vaxtype, dose: 2).first
                theMess = " Covax2 on " + @booker2.clinic.clinicdate.strftime("%d-%m-%Y") + " was also unbooked"
                @booker2.destroy
          end
        else
           if @booker2 = Booker.where(firstname: @booker.firstname, surname: @booker.surname,  dob: @booker.dob,  vaxtype: @booker.vaxtype, dose: 2).first
                theMess = " Covax2 on " + @booker2.clinic.clinicdate.strftime("%d-%m-%Y") + " was also unbooked"
                @booker2.destroy
          end
        end
      end      
      if @booker.clinic_id == 0 
          theMess = firstname + " " + surname + " " + @booker.vaxtype + " was removed from waiting list"
    
      else
          theMess = firstname + " " + surname + " " + @booker.vaxtype + @booker.dose.to_s + " on " + @booker.clinic.clinicdate.strftime("%d-%m-%Y") + " was unbooked." + theMess
      end
      @booker.destroy
      respond_to do |format|
      format.html { 
           redirect_to clinics_path(vaxtype: @vaxtype), notice: theMess
       }

    end

 end

 def emailreminders
    # not used
    params[:days] ? noDays = params[:days] : noDays = 1
    # find clinics on that day
    remindDate = Date.today + noDays.days
    clinics = Clinic.where(clinicdate: remindDate).all
    @reminders = []
    clinics.each do |clinic|
             clinic.bookers.each do |booker|
             unless booker.email.blank?
                    PatientMailer.email_reminder(booker.id).deliver_later
                    @reminders << [booker.surname,booker.firstname,booker.clinic.clinicdate,booker.emaildec]
              end

        end
    end




  end

  def email
        @reminders = []
        @clinic.bookers.each do |booker|
              if booker.emaildec  =~ URI::MailTo::EMAIL_REGEXP
                    PatientMailer.email_reminder(booker.id).deliver_later
                    @reminders << [booker.surname,booker.firstname,booker.clinic.clinicdate,booker.emaildec]
              end
        end
        @reminderType = "email"
        render :reminders


  end

  def sms
    # find clinics on that day

    if @clinic.clinicdate == Date.today
        theTerm = "today"
    elsif  @clinic.clinicdate == Date.tomorrow
        theTerm = "tomorrow"
    else 
        theTerm = "on " + clinic.clinicdate.strftime("%A, %B %d")
    end
    @reminders = []

    @clinic.bookers.each do |booker|
             msg = "Reminder - you have an immunisation appointment " + theTerm + " at " + view_context.formatTime(booker.bookhour,booker.bookminute)
             unless booker.mobile.blank?
                    mobile=formatMobile(booker.mobiledec)
                    if Phony.plausible?(mobile)
                     AgentTexter.reminder(mobile: mobile, msg: msg).deliver_later
                    end
                    @reminders << [booker.surname,booker.firstname,view_context.formatTime(booker.bookhour,booker.bookminute),mobile]
              end


    end
    @reminderType = "sms"
    render :reminders




 end


  def smsreminders
    # not used
    params[:days] ? noDays = params[:days] : noDays = 1
    # find clinics on that day
    remindDate = Date.today + noDays.days
    if noDays ==0
        theTerm ="today"
    end
    if noDays == 1
        theTerm ="tomorrow"
    end
    if noDays > 1
        theTerm = "on " + remindDate.strftime("%A, %B %d")
    end
    clinics = Clinic.where(clinicdate: remindDate).all
    @reminders = []
    clinics.each do |clinic|
             clinic.bookers.each do |booker|
             msg = "Reminder - you have an immunisation appointment " + theTerm + " at " + view_context.formatTime(booker.bookhour,booker.bookminute)
             unless booker.mobile.blank?
                    mobile=formatMobile(booker.mobiledec)
                    if Phony.plausible?(mobile)
                      AgentTexter.reminder(mobile: mobile, msg: msg).deliver_later
                    end
                    @reminders << [booker.surname,booker.firstname,view_context.formatTime(booker.bookhour,booker.bookminute),mobile]
              end

        end
    end




 end







 def updatecontacts
      @username = session[:username]
      @password = session[:password]
      @id=session[:id]
      @name=session[:name]
      @bookersupdated=[]
      connect_array=connect()
      @error_code=connect_array[1]
      if (@error_code==0)
           dbh=connect_array[0]
              clinics = Clinic.where("clinicdate >= ?",Date.today).all
              clinics.each do |clinic|
                  clinic.bookers.each do |booker|
                      #if booker.email.blank? or  booker.mobile.blank?
                            @patient = Patient.get_patient(booker.genie.to_s,dbh)
                            crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
                            booker.update_attributes(mobile: crypt.encrypt_and_sign(@patient.mobilephone), email: crypt.encrypt_and_sign(@patient.email))
                            @bookersupdated << [booker.firstname,booker.surname,@patient.mobilephone,@patient.email]
                      #end
                  end
              end
            dbh.disconnect
       else
            flash[:alert] = "Unable to connect to database. "+get_odbc
            flash[:notice] = connect_array[2]
            redirect_to  controller: "genie", action: "login"
      end

 end
   
 

 def sendReminder
      apptTime = Time.now
      reminderTime = apptTime.change({ hour: 8, minute:0 })
      #AgentTexter.alert(msg: "meeting at 7.30am").deliver
      AgentTexter.alert(mobile: "+61413740060", msg: "meeting at 7.30am").deliver_later
      AgentTexter.alert(mobile: "+61414320036", msg: "meeting at 7.30am").deliver_later
      AgentTexter.alert(mobile: "+61437094047", msg: "meeting at 7.30am").deliver_later
      AgentTexter.alert(mobile: "+61432296797", msg: "meeting at 7.30am").deliver_later
      AgentTexter.alert(mobile: "+61413740060", msg: "no meeting at 8.00am").deliver_later(wait_until: reminderTime)
      AgentTexter.alert(mobile: "+61414320036", msg: "mo meeting at 8.00am").deliver_later(wait_until: reminderTime)
      AgentTexter.alert(mobile: "+61437094047", msg: "no meeting at 8.00am").deliver_later(wait_until: reminderTime)
      AgentTexter.alert(mobile: "+61432296797", msg: "no meeting at 8.00am").deliver_later
 end

 def audit
      
      @username = session[:username]
      @password = session[:password]
      @id=session[:id]
      @name=session[:name]
      @bookersupdated=[]
      connect_array=connect()
      @error_code=connect_array[1]
      if (@error_code==0)
            dbh=connect_array[0]
            @clinic.auditgiven(dbh,true)
            missedvaxees = @clinic.auditmissed(dbh)
            @missed = []
            missedvaxees.each do | miss |
                unless Booker.where(genie: miss["PT_ID_FK"],clinic_id: @clinic.id).first
                    @patient = Patient.get_patient(miss["PT_ID_FK"].to_s, dbh)
                    @missed << @patient
                end
            end
            dbh.disconnect
       else
            flash[:alert] = "Unable to connect to database. "+get_odbc
            flash[:notice] = connect_array[2]
            redirect_to  controller: "genie", action: "login"
      end
 end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clinic
      @clinic = Clinic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def clinic_params
      params.require(:clinic).permit(:clinicdate, :live, :starthour, :startminute, :finishhour, :finishminute, :perhour, :vaxtype, :venue, :people, :template, :age, :ATSIage, :chronic, :chronicage, :message,:hour,:minute,:genie,:healthcare,:break,:bstarthour,:bstartminute,:bfinishhour,:bfinishminute,:pair1,:pair2,:pair3,:shownew,:invitenew,:inviteold,:pairmin,:pairmax,:pairpref)
    end
end
