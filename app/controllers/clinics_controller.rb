class ClinicsController < ApplicationController
  before_action :set_clinic, only: [:show, :edit, :update, :destroy, :book]

  # GET /clinics
  # GET /clinics.json
  def index

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


        params[:vaxtype] ? @vaxtype = params[:vaxtype] : @vaxtype = "Fluvax"

        if @vaxtype == "Covax"
            @clinics = Clinic.where(vaxtype: "Covax",template: false)
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


        params[:vaxtype] ? @vaxtype = params[:vaxtype] : @vaxtype = "Fluvax"

        if @vaxtype == "Covax"
            @clinics = Clinic.where(vaxtype: "Covax",template: false)
        elsif @vaxtype == "Fluvax"
            @clinics = Clinic.where(vaxtype: "Fluvax",template: false)
        else
            @clinics = Clinic.where(template: false)
        end

  end

  # GET /clinics/1
  # GET /clinics/1.json
  def show

  end

  # GET /clinics/new
  def new
    params[:vaxtype] == "Covax" ? @vaxtype="Covax" : @vaxtype="Fluvax"
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

    respond_to do |format|
      if @clinic.save
        format.html { redirect_to admin_clinics_url(vaxtype: @clinic.vaxtype), notice: 'Clinic was successfully created.' }
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
    respond_to do |format|
      if @clinic.update(clinic_params)
        format.html { redirect_to admin_clinics_url(vaxtype: @clinic.vaxtype), notice: 'Clinic was successfully updated.' }
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
    debugger
    # @clinic.destroy
    respond_to do |format|
      format.html { redirect_to clinics_url, notice: 'Clinic was successfully destroyed.' }
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
                        @booker.save
                        
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
                      where_clause = surname_text + firstname_text
                      puts "Where is " + where_clause
                      if where_clause!=""
                              sql = "SELECT Surname,FirstName,LastSeenDate,id,DOB FROM Patient WHERE " + where_clause + "ORDER BY Surname, FirstName"
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
           redirect_to clinics_url, notice: @booker.firstname + " " + @booker.surname + " was booked in for " + @booker.vaxtype.upcase + " on " + @clinic.clinicdate.strftime("%A, %B %d") + " at " + view_context.formatTime(@booker.bookhour,@booker.bookminute)
        end
       }

    end



 








 end
 def unbook
      @booker = Booker.find(params[:bookerID])
      firstname=@booker.firstname
      surname = @booker.surname
      @booker.destroy
      respond_to do |format|
      format.html { 
           redirect_to clinic_url, notice: @booker.firstname + " " + @booker.surname + " was unbooked."
       }

    end

 end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clinic
      @clinic = Clinic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def clinic_params
      params.require(:clinic).permit(:clinicdate, :live, :starthour, :startminute, :finishhour, :finishminute, :perhour, :vaxtype, :venue, :people, :template, :age, :ATSIage, :chronic, :chronicage, :message,:hour,:minute,:genie,:healthcare)
    end
end
