class RegistersController < ApplicationController
  before_action :set_register, only: [:show, :edit, :update, :destroy]

  # GET /registers
  # GET /registers.json
  def index
    @registers = Register.all

  end

  # GET /registers/1
  # GET /registers/1.json
  def show
    # show all the patients in a register
    
    connect_array=connect()
    @error_code=connect_array[1]
    if (@error_code==0)
          dbh=connect_array[0]
          patient_array=@register.members
          @patients=[]
          patient_array.each do |patient|
            @patients<< get_patient(patient.to_s,dbh)
          end
          dbh.disconnect

    end

  end

  # GET /registers/new
  def new
    @register = Register.new
  end

  # GET /registers/1/edit
  def edit
  end

  # POST /registers
  # POST /registers.json
  def create
    @register = Register.new(register_params)

    respond_to do |format|
      if @register.save
        format.html { redirect_to @register, notice: 'Register was successfully created.' }
        format.json { render :show, status: :created, location: @register }
      else
        format.html { render :new }
        format.json { render json: @register.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registers/1
  # PATCH/PUT /registers/1.json
  def update
    respond_to do |format|
      if @register.update(register_params)
        format.html { redirect_to @register, notice: 'Register was successfully updated.' }
        format.json { render :show, status: :ok, location: @register }
      else
        format.html { render :edit }
        format.json { render json: @register.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registers/1
  # DELETE /registers/1.json
  def destroy
    @register.destroy
    respond_to do |format|
      format.html { redirect_to registers_url, notice: 'Register was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private


    def get_patient(patient,dbh)
            # Get info about this patient
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, Scratchpad, FamilyHistory, MedicareNum, MedicareRefNum, IHI, HomePhone, MobilePhone, SmokingFreq, Alcohol, AlcoholInfo, LastMammogram, CultureCode, EmailAddress, LastSmear, NoPapRecall FROM Patient WHERE id = "+patient       
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            atsi=0
            row['CULTURECODE'] > 3 ? atsi=0 : atsi=1

            @patient=Patient.new(id: @id, surname: row['SURNAME'], firstname: row['FIRSTNAME'], fullname: row['FULLNAME'], lastseendate: row['LASTSEENDATE'], lastseenby: row['LASTSEENBY'], addressline1: row['ADDRESSLINE1'], addressline2: row['ADDRESSLINE2'],suburb: row['SUBURB'],dob: row['DOB'], age: row['AGE'], sex: row['SEX'], scratchpad: row['SCRATCHPAD'], social: row['FAMILYHISTORY'], ihi: row['IHI'],medicare: row['MEDICARENUM'].to_s + "/" + row['MEDICAREREFNUM'].to_s,homephone: row['HOMEPHONE'],mobilephone: row['MOBILEPHONE'], smoking: row['SMOKINGFREQ'], etoh: row['ALCOHOL'], etohinfo: row['ALCOHOLINFO'], mammogram: row['LASTMAMMOGRAM'], atsi: atsi, email: row['EMAILADDRESS'], pap: row['LASTSMEAR'],pap_recall: row['NOPAPREACLL'])
          end
          sth.drop
          return @patient
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_register
      @register = Register.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def register_params
      params.require(:register).permit(:name )
    end
end
