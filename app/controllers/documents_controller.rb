class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    if params.has_key?(:code)
      @documents = Document.where(code: params[:code])
    else
      if params[:all] == "true"
        @documents = Document.all
        @all = true

      else
        @documents = Document.where(patient:  0) 
        @all = false 
      end
    end

  end

  # GET /documents/1
  # GET /documents/1.json
  def show

  end

  # GET /documents/new
  def new

    @document = Document.new
    @source = "careplan"
    @source=params[:source] if params[:source]
    @returnPatient = 0
    @returnPatient = params[:patient_id] if params[:patient_id]
    @document.parent = 0
    if params.has_key?(:parent)
      @document.parent = params[:parent]
      if params[:parent] != "" and params[:parent] !="0"
        parent=Document.find(params[:parent])
        @document.code = parent.code
        @document.texttype = parent.texttype
        @document.name = parent.name
        @document.description = parent.description
        @document.content = parent.content
        @document.parent = params[:parent]
      end
    end
    if params.has_key?(:patient_id)
        @document.code = 1
        if params[:parent] != "" and params[:parent]!= "0"
          @document.patient_id = params[:patient_id]
        end
    end


  end

  # GET /documents/1/edit
  def edit
    @source=params['source']
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    flash[:notice] = 'Document was successfully created'
    respond_to do |format|
     
      if @document.save
        if params['returnPatient'] and params['returnPatient']!="0"
           if params['source']=="show"
             format.html { redirect_to :controller => :patient, :action => :show, :id => params['returnPatient'] }  
            else      
             format.html { redirect_to :controller => :patient, :action => :careplan, :id => params['returnPatient'] }  
            end
        else
            format.html { redirect_to :controller => :documents, notice: 'Document was successfully updated.' }
        end
        
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        if @document.patient_id != 0
           if params['source']=="show"
             format.html { redirect_to :controller => :patient, :action => :show, :id => @document.patient_id}  
            else      
             format.html { redirect_to :controller => :patient, :action => :careplan, :id => @document.patient_id}  
            end
        else
          format.html { redirect_to :controller => :documents, notice: 'Document was successfully updated.' }
        end
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:name, :description, :patient_id, :code, :parent, :texttype, :content)
    end
end
