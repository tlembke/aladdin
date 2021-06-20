class CasesController < ApplicationController
  before_action :set_case, only: [:show, :edit, :update, :destroy, :close]
  skip_before_filter :require_login, only: [:show]

  # GET /cases
  # GET /cases.json
  def index
    @cases = Case.all
  end

  # GET /cases/1
  # GET /cases/1.json
  def show
    # need to set session case to @case.id
      session[:case] = @case.id
      if session[:username]
          names = get_patient_name(@case.patient_id)
          @patient_name = names.firstname+" "+ names.surname

      end

  end

  # GET /cases/new
  def new
    # this is open existing or new if not existing
    @patient_id=0
    @patient_id=params[:patient_id] if params[:patient_id]
    theText = "opened"
    unless @case = Case.where(patient_id: @patient_id).first
        code = rand(36**8).to_s(36)
        while  Case.where(code: code).first
            code = rand(36**8).to_s(36)
        end
        @case = Case.new(code: code,patient_id: @patient_id)
        theText = "created"
        @case.save
    end
    unless @patient_id == 0
      
      redirect_to @case, notice: 'Case was successfully '  + theText
    end
  end

  # GET /cases/1/edit
  def edit
  end

  # POST /cases
  # POST /cases.json
  def create
    @case = Case.new(case_params)

    respond_to do |format|
      if @case.save
        format.html { redirect_to @case, notice: 'Case was successfully created.' }
        format.json { render :show, status: :created, location: @case }
      else
        format.html { render :new }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cases/1
  # PATCH/PUT /cases/1.json
  def update

    respond_to do |format|
      if @case.update(case_params)
        format.html { redirect_to @case, notice: 'Case was successfully updated.' }
        format.json { render :show, status: :ok, location: @case.code }
      else
        format.html { render :edit }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cases/1
  # DELETE /cases/1.json
  def destroy
    @case.destroy
    respond_to do |format|
      format.html { redirect_to cases_url, notice: 'Case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def close
      session[:case] = nil
      redirect_to docs_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_case
      @case = Case.find(params[:code])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def case_params
      params.require(:case).permit(:code, :patient_id, :message)
    end
end
