class StatusesController < ApplicationController
  before_action :set_status, only: [:show, :edit, :update, :destroy]


  # GET /statuses
  # GET /statuses.json
  def index
    @statuses = status.all
  end

  # GET /statuses/1
  # GET /statuses/1.json
  def show
  end

  # GET /statuses/new
  def new
    @status = status.new
  end

  # GET /statuses/1/edit
  def edit
  end

  # POST /statuses
  # POST /statuses.json
  def create
    @status = status.new(status_params)

    respond_to do |format|
      if @status.save
        format.html { redirect_to @status, notice: 'status was successfully created.' }
        format.json { render :show, status: :created, location: @status }
      else
        format.html { render :new }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

 # PATCH/PUT /stauses/1
  # PATCH/PUT /stauses/1.json
  def update

    respond_to do |format|
      
      if @status.update(status_params)
        format.js {}
        format.html { redirect_to @status, notice: 'Goal was successfully updated.' }
        format.json { render :show, status: :ok, location: @status }
      else
        debugger
        format.html { render :edit }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /statuses/1
  # DELETE /statuses/1.json
  def destroy
    @status.destroy
    respond_to do |format|
      format.html { redirect_to statuses_url, notice: 'status was successfully destroyed.' }
      format.json { head :no_content }
    end
  end








    private
    # Use callbacks to share common setup or constraints between actions.
    def set_status
      @status = Status.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def status_params
      params.require(:status).permit(:progress, :condition_id, :patient_id )
    end
end