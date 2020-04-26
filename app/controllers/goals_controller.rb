class GoalsController < ApplicationController
  before_action :set_goal, only: [:show, :edit, :update, :destroy, :touch]

  # GET /goals
  # GET /goals.json
  def index

      @master_items = []
      @masters=Master.all
      @masters.each do |x| 
        @master_items << {value: x.id, text: x.name}
      end

      @measure_items = [{value: 0, text: "None"}]
    
      @measures=Measure.all
      @measures.each do |x| 
        @measure_items << {value: x.id, text: x.name}
      end



    if params[:all] == "true"
      @goals = Goal.all
      @all = true

    else
      @goals = Goal.where(patient_id:  0) 
      @all = false 
    end
  end

  # GET /goals/1
  # GET /goals/1.json
  def show

    # Master goals have parent
  end

  # GET /goals/new
  def new


    @goal = Goal.new(patient_id: 0,condition_id: 0)
    if params[:patient]
        @goal.patient_id=params[:patient]
    end
    if params[:condition]
        @goal.condition_id=params[:condition]
    end
  end

  # GET /goals/1/edit
  def edit
  end

  # POST /goals
  # POST /goals.json
  def create
    params.permit(:mastercheck)
    puts params
    @goal = Goal.new(goal_params)
    unless @goal.patient_id > 0 
      # saving from goals controllerrather than patients controller
        if @goal.master_id==nil or @goal.master_id==""
          @goal.master_id=0
        end
    end

    if params['mastercheck'] and @goal.patient_id > 0
      # save twice - once for patient and once for master
      # masters have no patient id
      # if no patient, will be save approrpiately later

      @goal_master=Goal.new(goal_params)
      if @goal_master.master_id==nil
        @goal_master.master_id=0
      end
      @goal_master.patient_id=0
      @goal_master.save
      @goal.parent=@goal_master.id
    end
    if @goal.patient_id > 0 
      @goal.master_id=""
    end
    respond_to do |format|
      if @goal.save
        flash[:notice] = "Goal saved"
        # if patient id = 0 this has scome from goals not care plan
        format.js {}
        format.html { 
          if @goal.patient_id == 0 
            redirect_to controller: "goals", action: "index"
          else
            redirect_to controller: "patient", action: "careplan", id: @goal.patient_id
          end
        }
        format.json { render :show, status: :created, location: @goal }
      else
        format.html { render :new }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goals/1
  # PATCH/PUT /goals/1.json
  def update


    respond_to do |format|
      
      if @goal.update(goal_params)
        format.html { redirect_to @goal, notice: 'Goal was successfully updated.' }
        format.json { render :show, status: :ok, location: @goal }
      else
        format.html { render :edit }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  def touch
    respond_to do |format|
      if @goal.touch
        @message="Updated today"
        format.js {}
        format.html { redirect_to @paragraph, notice: 'Paragraph was successfully updated.' }
        format.json { render :show, status: :ok, location: @paragraph }
      else
        @message="Update failed"
        format.js {}
        format.html { render :edit }
        format.json { render json: @paragraph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goals/1
  # DELETE /goals/1.json
  def destroy
    @goal.destroy
    respond_to do |format|
      format.js{}
      format.html { redirect_to goals_url, notice: 'Goal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goal
      @goal = Goal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def goal_params
      params.require(:goal).permit(:title, :description, :by, :fallback1, :fallback2,  :condition_id, :patient_id, :measure_id, :active, :parent, :master_id, :target, :autoload)
    end
end
