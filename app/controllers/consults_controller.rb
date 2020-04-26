class ConsultsController < ApplicationController
  before_action :set_consult, only: [:show, :edit, :update, :destroy]

  # GET /consults
  # GET /consults.json
  def index

    whereS = ""
    @billed = true
    @complete = true
    if params[:commit]
      if params[:provider] and params[:provider] != "0" 
          whereS="provider_id = '" + params[:provider] +"'"
      end
      unless params[:billed]
        whereS = whereS + " AND " if whereS !=""
        whereS = whereS + "billed != 't'"
      end
      unless params[:complete]
         whereS = whereS + " AND " if whereS !=""
          whereS = whereS + "complete != 't'"
      end
      @billed = params[:billed]
      @complete = params[:complete]
    end
    if whereS == ""
        @consults = Consult.all
    else
        @consults = Consult.where(whereS)
    end

    @delivery = ["","C","H","P","V"]
    @consulttime = ["","I","A","U"]

  



    
  
    @users=get_users
    @users.unshift(["All",0])

  end

  # GET /consults/1
  # GET /consults/1.json
  def show
  end

  # GET /consults/new
  def new
    @consult = Consult.new
  end

  # GET /consults/1/edit
  def edit
  end

  # POST /consults
  # POST /consults.json
  def create
    @consult = Consult.new(consult_params)

    respond_to do |format|
      if @consult.save
        format.html { redirect_to @consult, notice: 'Consult was successfully created.' }
        format.json { render :show, status: :created, location: @consult }
      else
        format.html { render :new }
        format.json { render json: @consult.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /consults/1
  # PATCH/PUT /consults/1.json
  def update
    respond_to do |format|
      if @consult.update(consult_params)
        format.html { redirect_to @consult, notice: 'Consult was successfully updated.' }
        format.json { render :show, status: :ok, location: @consult }
      else
        format.html { render :edit }
        format.json { render json: @consult.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
      @consult=Consult.find(params[:id])

      if params[:pram] == "billed"
        @consult.billed ? @consult.billed = false : @consult.billed = true
      end
      if params[:pram] == "complete"
        @consult.complete ? @consult.complete = false : @consult.complete = true
      end
      @consult.save
      render :nothing => true



  end




  # DELETE /consults/1
  # DELETE /consults/1.json
  def destroy
    @consult.destroy
    respond_to do |format|
      format.html { redirect_to consults_url, notice: 'Consult was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consult
      @consult = Consult.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def consult_params
      params.require(:consult).permit(:provider_id, :patient_id, :consultdate, :mbs, :columntype, :notes, :billed, :complete, :fullname, :providername, :billingnote, :consulttime, :delivery)
    end
end
