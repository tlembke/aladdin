class BookersController < ApplicationController
  before_action :set_booker, only: [:show, :edit, :update, :destroy, :pair, :confirm,:invite]

  # GET /bookers
  # GET /bookers.json
  def index
    @bookers = Booker.all
  end

  # GET /bookers/1
  # GET /bookers/1.json
  def show
  end

  # GET /bookers/new
  def new
      @booker = Booker.new
      params[:vaxtype] ? @vaxtype = params[:vaxtype] : @vaxtype = "CovaxP"
    # this is for waiting list people
    # normal bookers are booked thorugh clinics controller
      theMess =""
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
                        

                       
                        @booker.genie = params[:genie]
                        if @booker.genie == 0

                          @booker.surname = params[:Surname]
                          @booker.firstname =params[:FirstName]
                          #@booker.dob = @patient.dob
                          @booker.vaxtype = @vaxtype
                          @booker.clinic_id = 0


                          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
                          
                          @booker.mobile = crypt.encrypt_and_sign(params[:mobile])

                          theMess = @booker.firstname + " " + @booker.surname + " added to " + @booker.vaxtype + " waiting list."
                        else


                          @patient = Patient.get_patient(params[:genie],dbh)
                          @booker.surname = @patient.surname
                          @booker.firstname =@patient.firstname
                          @booker.dob = @patient.dob
                          @booker.vaxtype = @vaxtype
                          @booker.clinic_id = 0

                          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
                          @booker.email = crypt.encrypt_and_sign(@patient.email)
                          @booker.mobile = crypt.encrypt_and_sign(@patient.mobilephone)

                        end

                        @booker.dose=1
       
                        @booker.save
                        theMess = @booker.firstname + " " + @booker.surname + " added to " + @booker.vaxtype + " waiting list."


                        
                    elsif params[:Surname] # ie search




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
                    @surname =params[:Surname]
                    @firstname = params[:FirstName]

                  
                  dbh.disconnect

                
           else
                  flash[:alert] = "Unable to connect to database. "+get_odbc
                  flash[:notice] = connect_array[2]
                  redirect_to  controller: "genie", action: "login"
            end


      end

      respond_to do |format|
         unless theMess==""
            flash[:notice] = theMess
          end
         format.html

      end



 
















  end # end new

  # GET /bookers/1/edit
  def edit
  end

  # POST /bookers
  # POST /bookers.json
  def create

    @booker = Booker.new(booker_params)

    respond_to do |format|
      if @booker.save
        format.html { redirect_to @booker, notice: 'Booker was successfully created.' }
        format.json { render :show, status: :created, location: @booker }
      else
        format.html { render :new }
        format.json { render json: @booker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookers/1
  # PATCH/PUT /bookers/1.json
  def update

    respond_to do |format|
      if @booker.update(booker_params)
        format.html { redirect_to @booker, notice: 'Booker was successfully removed from waiting list.' }
        format.json { render :show, status: :ok, location: @booker }
      else
        format.html { render :edit }
        format.json { render json: @booker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookers/1
  # DELETE /bookers/1.json
  def destroy
    @booker.destroy
    respond_to do |format|
      format.html { redirect_to waiting_bookers_url, notice: "Booker was successfully destroyed."}
      format.json { head :no_content }
    end
  end

  def pair
        # find appt to pair with
        @theMessage = "Unable to Pair"

        nextAppt = Clinic.findTime(@booker.clinic.pair1)
        useClinic=@booker.clinic.pair1
        if nextAppt==nil and @booker.clinic.pair2 !=nil
             useClinic=@booker.clinic.pair2
             nextAppt=Clinic.findTime(@booker.clinic.pair2)
        end
                           
        if nextAppt
     
            
            @booker2=@booker.dup
            @booker2.clinic_id = useClinic
            @booker2.dose=2
            @booker2.bookhour = nextAppt[0]
            @booker2.bookminute = nextAppt[1]
            @booker2.save   
            @theMessage = @booker2.clinic.clinicdate.strftime("%d-%m-%y")+ "  " + view_context.formatTime(@booker2.bookhour,@booker2.bookminute)


            @patient = Patient.getPatientMini(@booker.genie)


            unless @patient.email.blank?

                            PatientMailer.second_booked(@booker.id,@patient.email).deliver_later
             end 
   
        end


  end

  def waiting
      if params[:vaxtype]
        @bookers= Booker.where(clinic_id: 0, vaxtype: params[:vaxtype]).order(:created_at)
      else
        @bookers= Booker.where(clinic_id: 0).order(:created_at)
      end

  end

  def confirm
      @booker.confirm ? @booker.confirm = false : @booker.confirm = true
      @booker.save
      render :nothing => true 
  end
  def invite
      @booker.invite = true
      @booker.save
      render :nothing => true 
  end



  def sendWaitMessage
    # find clinics on that day
    
    if params[:mess]
      @theMessage = params[:theMessage]
      if @theMessage == ""
          @theMessage = "There may be immunisation clinics available now at https://vax.alstonville.clinic"
      end

      @reminders=[]
      @noreminders=[]

      params[:mess].each do |booker_id|
               if booker=Booker.find(booker_id)
                 unless booker.mobile.blank?
                        mobile=formatMobile(booker.mobiledec)
                        @newMessage = @theMessage.gsub("{{firstname}}", booker.firstname)
                        if Phony.plausible?(mobile)
                               AgentTexter.reminder(mobile: mobile, msg: @newMessage).deliver_later
                          @reminders << [booker.surname,booker.firstname,@newMessage,mobile]
                        else
                          @noreminders << [booker.surname,booker.firstname,mobile]
                        end
                        
                  end
              end


      end

    end



 end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booker
      @booker = Booker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booker_params
      params.require(:booker).permit(:clinic_id, :genie, :surname, :firstname, :dob, :vaxtype, :contactby, :confirm, :received, :arm, :dose, :batch, :note, :bookhour, :bookminute,:email,:eligibility)
    end
end
