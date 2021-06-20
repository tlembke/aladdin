class DocsController < ApplicationController
  before_action :set_doc, only: [:show, :edit, :update, :destroy, :addcase]
  # This controller is for docuemnts in the library, which includes those uploaded as well as those writted using the document controller

  # GET /docs
  # GET /docs.json
  def index
    processNewDocs
    if session[:case]
      @case = Case.find(session[:case])
      names = get_patient_name(@case.patient_id)
     @patient_name = names.firstname+" "+ names.surname
    end
 

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
       catarray=%w[Any Handout Form Resource Policy]
       @showing="Showing " + ActionController::Base.helpers.pluralize(@docs.count, 'result')
       
       @showing2 = @showing2 + " for '" + params[:searchterm] +"'"unless params[:searchterm].blank?
       unless params[:tag].blank?
           @showing2 = @showing2 + " OR" unless params[:searchterm].blank?
           @showing2 = @showing2 + " Tagged '" + params[:tag] +"' "
       end

       
       @showing2 = @showing2 +" IN CATEGORY '" + catarray[params[:cat].to_i] + "'" unless params[:cat] == "0"
       
    else
      if params[:all]
        @docs=Doc.all
        @showing="Showing all " + @docs.count.to_s + " documents"
      elsif params[:untagged]
        
        # @docs=Doc.includes(:tags).where("tag.id is null")
       # @docs=Doc.where.not(id: tag.doc.select(:id))
      # @docs= Doc.find(:all, :conditions => ["docs.id NOT IN (?)", @tag.doc_ids])
      @docs = Doc.includes(:docs_tags).where(docs_tags: {doc_id: nil})
        @showing="Showing all "+ @docs.count.to_s + " untagged documents"
      else
        
        @docs= Doc.all.order(created_at: :DESC).limit(20)
        @showing="Showing 20 most recent documents"
      end

    end
  end

  # GET /docs/1
  # GET /docs/1.json
  def show
  end

  # GET /docs/new
  def new
    @doc = Doc.new

    if params[:web] == "true"
        @web=true
    end
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
    @doc = Doc.new(doc_params)
    if params[:web] == "true"
        @doc.filename = doc_params[:filename]
        unless @doc.filename.starts_with? "http://" or @doc.filename.starts_with? "https://"
            @doc.filename = "http://" + @doc.filename
        end
        theFilename = "#{SecureRandom.urlsafe_base64}.png"
        screenshot(@doc.filename,theFilename)
        @doc.thumbnail = theFilename


    else
   

              # see if a new file has been uploaded
          docfolder = Pref.docfolder

          
                
                # upload file selected
                
                  
          uploaded_io = doc_params[:uploaded_doc]
          File.open(::Rails.root.join('public','library','new',uploaded_io.original_filename), 'wb') do |file|
                file.write(uploaded_io.read)
          end
               
               


          
          
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

  end

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

  def screenshot(url,theFilename)
      #  https://github.com/nezirz/ruby_webshot
  
         # ws = Webshot::Screenshot.instance
         # screenshot =  ws.capture "#{params[:url_grab]}", ::Rails.root.join('public','library','thumbnails','screenshot5.png'), width: 500, height: 250
        # RubyWebshot.call("#{params[:url_path]}",{:save_file_path=> ::Rails.root.join('public','library','thumbnails'), :file_name =>"screenshot10png"})
         RubyWebshot.call(url,{:save_file_path=> ::Rails.root.join('public','library','thumbnails'),:file_name => theFilename})
           
  
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


   def addcase

      id=params[:id]
      case_id=params[:case_id]

      @casedoc =CasesDoc.where("doc_id= ? and case_id = ?",id,case_id).first
    
      if @casedoc
          
            @doc.cases.delete(case_id)

      else
            @newcasedoc=CasesDoc.new(doc_id: id, case_id: case_id)
            #@new_register.update_attribute(:register_id, register_id)
            #@new_register.update_attribute(:patient_id, id)
            @newcasedoc.save
      end
      render :nothing => true 
 end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @doc = Doc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def doc_params
      params.require(:doc).permit(:name, :filename, :thumbnail, :description, :cat, :tag_string, :uploaded_doc,:search,:web)
    end
end
