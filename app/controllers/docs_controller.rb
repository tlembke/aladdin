class DocsController < ApplicationController
  before_action :set_doc, only: [:show, :edit, :update, :destroy]

  # GET /docs
  # GET /docs.json
  def index
    processNewDocs
    @searchtermDefault = params[:searchterm]
    @tagDefault = params[:tag]
    @catDefault = params[:cat].to_i
    @showing2 = ""

    unless params[:searchterm].blank? and params[:tag].blank? and (params[:cat] == "0" or params[:cat].blank?)
       
       searchterm= params[:searchterm].downcase.strip
       unless params[:tag].blank?
            searchterm = params[:tag].downcase.strip + " " + searchterm
            searchterm = searchterm.strip
       end
       
       terms = searchterm.split
          @alldocs=[]
          catText=""
          if params[:cat].to_i > 0
              
               
              
                  catText = " AND docs.cat = '"+ params[:cat] + "' "
              
          end
          if terms.count > 0
              terms.each do |term|
                  term=term.strip
                   searchtermL = "%"+ term +"%"
                   #@docs = Doc.includes(:tags).where('tags.name' => searchterm or "'docs.name' LIKE ? or 'docs.description' LIKE ?,"%#{:searchterm}%","%#{:searchterm}%").all

                    @alldocs << Doc.includes(:tags).where("(docs.name LIKE '" + searchtermL + "' OR docs.description LIKE '" + searchtermL + "' OR tags.name = '" + term + "')"+catText).references(:tags)
              end
          else
              if params[:cat].to_i > 0
                    @alldocs << Doc.includes(:tags).where("docs.cat = " + params[:cat])
    
              end
          end


          #@docs=@alldocs.flatten.uniq
          @docs=@alldocs.flatten.group_by {|i| i}.sort_by {|_, a| -a.count}.map &:first

      # @docs = Doc.where('name LIKE ? or description LIKE ? or tags = ?', "%#{params[:searchterm]}%","%#{params[:searchterm]}%" , "%#{params[:searchterm]}%")
       catarray=%w[Any Handout Form Resource]
       @showing="Showing " + ActionController::Base.helpers.pluralize(@docs.count, 'result')
       
       @showing2 = @showing2 + " for '" + params[:searchterm] +"'"unless params[:searchterm].blank?
       unless params[:tag].blank?
           @showing2 = @showing2 + " OR" unless params[:searchterm].blank?
           @showing2 = @showing2 + " Tagged '" + params[:tag] +"' "
       end

       
       @showing2 = @showing2 +" IN CATEGORY '" + catarray[params[:cat].to_i] + "'" unless params[:cat] == "0"
       
    else
      @docs= Doc.recent(20)
      @showing="Showing 20 most recent documents"

    end
  end

  # GET /docs/1
  # GET /docs/1.json
  def show
  end

  # GET /docs/new
  def new
    @doc = Doc.new
  end

  # GET /docs/1/edit
  def edit
     tag_array=[]
     @doc.tags.each do |tag|
         tag_array << tag.name
     end
     @doc.tag_string = tag_array.reject(&:blank?).join(',')

  end

  # POST /docs
  # POST /docs.json
  def create
   

        # see if a new file has been uploaded
    docfolder = Pref.docfolder

    
          
          # upload file selected
          
            
    uploaded_io = doc_params[:uploaded_doc]
    File.open(::Rails.root.join('public','library','new',uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
    end
         
         


    
    @doc = Doc.new(doc_params)
    @doc.filename = uploaded_io.original_filename

    # make sure that filename is unique
    found = true
    i=1
    theFilename = @doc.filename
    while found
      if Doc.where(filename: theFilename).first
        theFilenameArray = @doc.filename.split(".")
        theFilename = theFilenameArray[0]+ "_" + i.to_s + "." + theFilenameArray[1]
        i=i+1
    
      else
   
        found = false
      end
    end
    fileOld = ::Rails.root.join('public','library','new', @doc.filename)
    @doc.filename = theFilename
    fileNew = ::Rails.root.join('public','library', @doc.filename)

    #reanme and move
    
    File.rename fileOld, fileNew

    # create thumbnail
     f = fileNew
     begin
            image=MiniMagick::Image.open(f)
            image.format("png", 0)
            image.resize("420x594")
            image.write(::Rails.root.join('public','library','thumbnails',File.basename(f, ".*")+ '.png'))
     rescue
            # file couldn't be processed by MiniMagick so use default file which is oops.png
            FileUtils.cp Rails.root.join('public','fax','oops.png'), Rails.root.join('public','library','thumbnails',File.basename(f, ".*") + '.png')
    end

    @doc.thumbnail = File.basename(f, ".*") + '.png'

    # all looks good. We can move now to the main foler with the new name
 

    respond_to do |format|
      if @doc.save
        @doc.save_tags(doc_params['tag_string'])
        format.html { redirect_to @doc, notice: 'Doc was successfully created.' }
        format.json { render :show, status: :created, location: @doc }
      else
        format.html { render :new }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /docs/1
  # PATCH/PUT /docs/1.json
  def update
    respond_to do |format|
      if @doc.update(doc_params)
         @doc.save_tags(doc_params['tag_string'])
        format.html { redirect_to @doc, notice: 'Doc was successfully updated.' }
        format.json { render :show, status: :ok, location: @doc }
      else
        format.html { render :edit }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end


  def processNewDocs
    cat = [0,1, 2, 3]
    %w[Handout Form Resource]
    catWords=[]
    catWords[1]="Handout"
    catWords[2]="Form"
    catWords[3]="Resource"
    for nextcat in cat do
 
      if nextcat==0
        newFolder = ::Rails.root.join('public','library','new',"*.*")
      else
        newFolder = ::Rails.root.join('public','library','new',catWords[nextcat],"*.*")
      end
      pendingfiles = Dir.glob(newFolder)
      
      pendingfiles.each do |file|
          # check for uniqueness
              # make sure that filename is unique
          found = true
          i=1
          theFilename = File.basename(file)
       
          while found
            if Doc.where(filename: theFilename).first
              theFilenameArray = theFilename.split(".")
              theFilename = theFilenameArray[0]+ "_" + i.to_s + "." + theFilenameArray[1]
              i=i+1
          
            else
         
              found = false
            end

          end


          

         #reanme and move
          fileNew = ::Rails.root.join('public','library', theFilename)
          File.rename file, fileNew

          # create thumbnail
          f = fileNew
          begin
            image=MiniMagick::Image.open(f)
            image.format("png", 0)
            image.resize("420x594")
            image.write(::Rails.root.join('public','library','thumbnails',File.basename(f, ".*")+ '.png'))
          rescue
            # file couldn't be processed by MiniMagick so use default file which is oops.png
            FileUtils.cp Rails.root.join('public','fax','oops.png'), Rails.root.join('public','library','thumbnails',File.basename(f, ".*") + '.png')
          end

          thumbnail = File.basename(f, ".*") + '.png'

          # guess a name from filename
          nameOfFile = File.basename(f, ".*").titleize

          # save file in database
          @doc=Doc.new(name: nameOfFile, thumbnail: thumbnail, filename: theFilename, cat: nextcat)
          @doc.save






      end
    end

  end


  # DELETE /docs/1
  # DELETE /docs/1.json
  def destroy
    @doc.destroy
    respond_to do |format|
      format.html { redirect_to docs_url, notice: 'Doc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @doc = Doc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def doc_params
      params.require(:doc).permit(:name, :filename, :thumbnail, :description, :cat, :tag_string, :uploaded_doc,:seacrh)
    end
end