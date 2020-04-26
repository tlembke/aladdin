class ItemnumbersController < ApplicationController
  before_action :set_itemnumber, only: [:show, :edit, :update, :destroy]

  # GET /itemnumbers
  # GET /itemnumbers.json
  def index
    @itemnumbers = Itemnumber.all
  end

  # GET /itemnumbers/1
  # GET /itemnumbers/1.json
  def show
  end

  # GET /itemnumbers/new
  def new
    @itemnumber = Itemnumber.new
  end

  # GET /itemnumbers/1/edit
  def edit
  end

  # POST /itemnumbers
  # POST /itemnumbers.json
  def create
    @itemnumber = Itemnumber.new(itemnumber_params)

    respond_to do |format|
      if @itemnumber.save
        format.html { redirect_to @itemnumber, notice: 'Itemnumber was successfully created.' }
        format.json { render :show, status: :created, location: @itemnumber }
      else
        format.html { render :new }
        format.json { render json: @itemnumber.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /itemnumbers/1
  # PATCH/PUT /itemnumbers/1.json
  def update
    respond_to do |format|
      if @itemnumber.update(itemnumber_params)
        format.html { redirect_to @itemnumber, notice: 'Itemnumber was successfully updated.' }
        format.json { render :show, status: :ok, location: @itemnumber }
      else
        format.html { render :edit }
        format.json { render json: @itemnumber.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /itemnumbers/1
  # DELETE /itemnumbers/1.json
  def destroy
    @itemnumber.destroy
    respond_to do |format|
      format.html { redirect_to itemnumbers_url, notice: 'Itemnumber was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_itemnumber
      @itemnumber = Itemnumber.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def itemnumber_params
      params.require(:itemnumber).permit(:name, :mbs, :sort)
    end
end
