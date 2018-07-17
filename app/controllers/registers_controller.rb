class RegistersController < ApplicationController
  before_action :set_register, only: [:show, :edit, :update, :destroy]

  # GET /registers
  # GET /registers.json
  def index
    
    @code=params[:code]
    if @code
        @registers = Register.where(code: @code).all
    else
        @registers = Register.all
    end


  end

  # GET /registers/1
  # GET /registers/1.json
  def show
    # show all the patients in a register

    # do we need to load the register for the first time
     connect_array=connect()
    @error_code=connect_array[1]
    if (@error_code==0)
        dbh=connect_array[0] 


            

        if @register.loaded == nil or params[:reload] == 'true'
            @register.load(dbh)

        end

        # get all the cells for the register
        @members=@register.members# this is not sorted and just contains ids
        #@patients=[]

        # sort by.header
        #which heaeder are we sorting by
        if params[:header] 
              sort_header = Header.find(params[:header])
        else
              sort_header =Header.where(name: :name, register_id: @register.id).first
        end
        params[:direction] ? sort_direction = params[:direction] : sort_direction = "asc"


        if sort_header.code == "date" or sort_header.code == "consult" or sort_header.name == "last"  or sort_header.name == "next" 
              @cells= Cell.where(header_id: sort_header.id).order(date:  sort_direction)
        else 
              @cells= Cell.where(header_id: sort_header.id).order(value:  sort_direction)
        end

        @patients=[]

        @cells.each do |cell|
              if @members.include?(cell.patient_id)
                 @patients << cell.patient_id
              end
        end
      



        @headers=@register.headers.order(:sort)

        dbh.disconnect
      else
          flash[:alert] = "Unable to connect to database. "+get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  controller: "genie", action: "login"
      end

    
  end

  # GET /registers/new
  def new
    @register = Register.new
    @register.code = params[:code]
  end

  # GET /registers/1/edit
  def edit
  end

  # POST /registers
  # POST /registers.json
  def create
    @register = Register.new(register_params)


    # need to create intital headers
    if @register.steal == ""
        # create name age headers
        Header.create(register_id: @register.id, name: "name", code: "string", sort: 1, special: true )
        Header.create(register_id: @register.id, name: "age", code: "string", sort: 3, special: true )

    else
        @headers = Header.where(register_id: @register.steal).all
        @headers.each do |h|
        Header.create(register_id: @register.id, name: h.name, code: h.code, keyword: h.keyword, sort: h.sort, special: h.special)
     end
    

    end



    respond_to do |format|
      if @register.save
        if @register.steal == ""
        # create name age headers
            Header.create(register_id: @register.id, name: "name", code: "string", sort: 1, special: true )
            Header.create(register_id: @register.id, name: "age", code: "string", sort: 3, special: true )

        else
            @headers = Header.where(register_id: @register.steal).all
            @headers.each do |h|
                Header.create(register_id: @register.id, name: h.name, code: h.code, keyword: h.keyword, sort: h.sort, special: h.special)
            end
        end
        format.html { redirect_to @register, notice: 'Register was successfully created.' }
        format.json { render :index, status: :created}
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
    Register.find(params[:id]).delete
    respond_to do |format|
      format.html { redirect_to registers_url, notice: 'Register was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private









    # Use callbacks to share common setup or constraints between actions.
    def set_register
      @register = Register.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def register_params
      params.require(:register).permit(:name, :code, :keyword, :steal, :special )
    end
end
