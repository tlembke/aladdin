class PhonetimesController < ApplicationController
  before_action :set_phonetime, only: [:show, :edit, :update, :destroy]

  # GET /phonetimes
  # GET /phonetimes.json
  def index
    @phonetimes = Phonetime.all
    @doctors_array=get_doctors
    @doctors=@doctors_array[0]
    @doctors_h=@doctors_array[1]
  end

  # GET /phonetimes/1
  # GET /phonetimes/1.json
  def show
    @doctors_array=get_doctors
    @doctors=@doctors_array[0]
    @doctors_h=@doctors_array[1]

  end

  # GET /phonetimes/new
  def new
    @phonetime = Phonetime.new
    @doctors_array=get_doctors
    @doctors=@doctors_array[0]
    @doctors_h=@doctors_array[1]
    @new_doctors=[]
    @doctors.each do|doctor|

      unless Phonetime.find_by_doctor_id(doctor[1])
        @new_doctors << doctor
      end
    end



  end

  # GET /phonetimes/1/edit
  def edit
    @doctors_array=get_doctors
    @doctors=@doctors_array[0]
    @doctors_h=@doctors_array[1]
  end

  # POST /phonetimes
  # POST /phonetimes.json
  def create
    @phonetime = Phonetime.new(phonetime_params)
    # delete old phonetime for that user



    respond_to do |format|
      if @phonetime.save
        format.html { redirect_to @phonetime, notice: 'Phonetime was successfully created.' }
        format.json { render :show, status: :created, location: @phonetime }
      else
        format.html { render :new }
        format.json { render json: @phonetime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phonetimes/1
  # PATCH/PUT /phonetimes/1.json
  def update
    respond_to do |format|
      if @phonetime.update(phonetime_params)
        format.html { redirect_to @phonetime, notice: 'Phonetime was successfully updated.' }
        format.json { render :show, status: :ok, location: @phonetime }
      else
        format.html { render :edit }
        format.json { render json: @phonetime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phonetimes/1
  # DELETE /phonetimes/1.json
  def destroy
    @phonetime.destroy
    respond_to do |format|
      format.html { redirect_to phonetimes_url, notice: 'Phonetime was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phonetime
      @phonetime = Phonetime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phonetime_params
      params.require(:phonetime).permit(:doctor_id, :message)
    end

    def get_doctors
       @username = session[:username]
       @password = session[:password]
       @id=session[:id]
       @name=session[:name]

       connect_array=connect()
       @error_code=connect_array[1]
       if (@error_code==0)
            dbh=connect_array[0]
            sql = "SELECT Id, Name FROM Preference where ProviderType = 2 and Inactive = false"
            puts sql
            sth = dbh.run(sql)
            doctors=[]
            doctors_h=Hash.new
            sth.fetch_hash do |row|
            doctor=[row['NAME'],row['ID']]
            doctors_h[row['ID'].to_s] = row['NAME']
            doctors << doctor
          end

          sth.drop
          dbh.disconnect
       else
            flash[:alert] = "Unable to connect to database. "+ get_odbc
            flash[:notice] = connect_array[2]
            redirect_to  action: "login"
       end
       doctors_array=[doctors,doctors_h]
       return doctors_array
    end

end
