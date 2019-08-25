class PatientRecallController < ApplicationController
before_action :set_recall, only: [:show, :edit, :update, :destroy]

  # GET /recalls
  # GET /recalls.json
  def index
    @patient_recalls = PatientRecall.all
  end

  # GET /recalls/1
  # GET /recalls/1.json
  def show
  end

  # GET /recalls/new
  def new
    @patient_recall = PatientRecall.new
  end

  # GET /recalls/1/edit
  def edit
  end

  # POST /recalls
  # POST /recalls.json
  def create
    @patient_recall = PatientRecall.new(patient_recall_params)

    respond_to do |format|
      if @patient_recall.save
        format.html { redirect_to @patient_recall, notice: 'Recall was successfully created.' }
        format.json { render :show, status: :created, location: @patient_recall }
      else
        format.html { render :new }
        format.json { render json: @patient_recall.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recalls/1
  # PATCH/PUT /recalls/1.json
  def update
    respond_to do |format|
      if @patient_recall.update(patient_recall_params)
        format.html { redirect_to @patient_recall, notice: 'Recall was successfully updated.' }
        format.json { render :show, status: :ok, location: @patient_recall }
      else
        format.html { render :edit }
        format.json { render json: @patient_recall.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recalls/1
  # DELETE /recalls/1.json
  def destroy
    @patient_recall.destroy
    respond_to do |format|
      format.html { redirect_to patient_recalls_url, notice: 'Recall was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient_recall
      @patient_recall = PatientRecall.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_recall_params
      params.require(:patient_recall).permit(:title, :cat)
    end
end
