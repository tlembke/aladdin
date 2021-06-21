class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
    # This controller is for docuemnts written in Aladdin. They will aso be cataloged in the docs database

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
    @print=false
    if params[:print]
      @print=true
    end
    @source = params['source']
    render layout: "nonavbar"
    
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
    if @document.doc
       tag_array=[]
       @document.doc.tags.each do |tag|
           tag_array << tag.name
       end
       @tag_string = tag_array.reject(&:blank?).join(',')
     end
     @source=params['source']
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    flash[:notice] = 'Document was successfully created'
    respond_to do |format|

      
     
      if @document.save
                # also need to add to docs unless @document has a patient
         
        if @document.patient_id == 0 or @document.patient_id.blank?
                cat = 3
                case @document.code
                when 1 
                  cat=1
                when 2
                  cat=1
                when 3
                  cat=4
                when 4
                  cat =3
                end



                @document.doc=Doc.new(name: @document.name, description: @document.description,filename: "local-" + @document.id.to_s,cat: cat)
                @document.doc.thumbnail = createThumbnail(@document)
                @document.doc.save
                @document.update(doc_id: @document.doc.id)

                @document.doc.save_tags(params['tag_string'])
        end 
        if params['returnPatient'] and params['returnPatient']!="0"
           if params['source']=="show"
             format.html { redirect_to :controller => :patient, :action => :show, :id => params['returnPatient'] }  
            else 
             format.html { redirect_to :controller => :patient, :action => :careplan, :id => params['returnPatient'] }  
            end
        else
            if params['source']=="library"
              format.html { redirect_to document_path(@document, source: :library), notice: 'Document was successfully created.' }
            else
              format.html { redirect_to :controller => :documents, notice: 'Document was successfully updated.' }
            end
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
        if @document.patient_id == 0 or @document.patient_id.blank?
                cat = 3
                case @document.code
                when 1 
                  cat=1
                when 2
                  cat=1
                when 3
                  cat=4
                when 4
                  cat =3
                end

                @document.doc.name = @document.name
                @document.doc.description =  @document.description
                @document.doc.cat = cat
             
                @document.doc.thumbnail = createThumbnail(@document)

                @document.doc.save
                @document.doc.save_tags(params['tag_string'])
        end
       
        if @document.patient_id != 0
           if params['source']=="show"
             format.html { redirect_to :controller => :patient, :action => :show, :id => @document.patient_id}  
            else      
             format.html { redirect_to :controller => :patient, :action => :careplan, :id => @document.patient_id}  
            end
        else
            format.html { redirect_to document_path(@document, source: :library), notice: 'Document was successfully created.' }
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
    #also need to destroy doc if exists
    if @document.doc
      @document.doc.destroy
    end
    respond_to do |format|
      format.js{}
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def createThumbnail(document)
    begin
              f=::Rails.root.join('public','library','thumbnails','blank-thumbnail.png')
              image=MiniMagick::Image.open(f)
              image.format("png", 0)
              image.resize("420x594")
              theText=view_context.strip_tags(document.content)
              theTextArray = breakuptext(theText,100,50)
              theTitle=document.name
              theTitle.gsub!("\"","")
              theTitle.gsub!("\'","")
              image.combine_options do |c|
                    c.pointsize 20
                    c.draw "text 10,20 '#{theTitle}'"
                    c.pointsize 10
                    yCount=35
                    wrap = 50
                    theTextArray.each do |nextline|
                        nextline.gsub!("\"","")
                        nextline.gsub!("\'","")
                        c.draw "text 10,#{yCount} '#{nextline}'"
                        yCount=yCount+15
                    end
              end
              image.write(::Rails.root.join('public','library','thumbnails',document.id.to_s+'.png'))
              thumbnail = document.id.to_s + ".png"

    rescue
              #thumbnail = "aladdin-document.png"
     end    
    end
    def breakuptext(theText,wrap,lines)

       
        linecount=0
        theTextArray=[]
        theText.each_line do |nextline|
          wrapcount=0
          while wrapcount < nextline.length
              if linecount < lines
                theTextArray << nextline[wrapcount..wrapcount+wrap]
              end
              wrapcount = wrapcount +  wrap
              linecount=linecount+1

          end
        end
        return theTextArray
    end

    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:name, :description, :patient_id, :code, :parent, :texttype, :content)
    end
end
