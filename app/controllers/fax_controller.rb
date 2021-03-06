class FaxController < ApplicationController
  def index
  			# @files = Dir.glob("/Users/tlembke/Documents/*.pdf")

  			
  			faxfolder = Pref.faxfolder

  			if request.post?
  				
  				# upload file selected
  				if params[:commit] == "Upload file"
		  		 	
				    uploaded_io = params[:fax]
				    File.open(faxfolder +"/" + uploaded_io.original_filename, 'wb') do |file|
		  				file.write(uploaded_io.read)
					end

    	 		else

    	 			#check what faxes are in the main fax folder
    	 			#faxes that have a post parameter have been selected to be sent
    	 			 @files = Dir.glob(faxfolder+"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
	  				 @faxes=[]
	  			 	 @files.each do |f|

	  			 	 	# find faxes to be sent
	  			 	 	if params[File.basename(f)] and params[File.basename(f)] != ""

	  			 	 			if params[File.basename(f)] == "trash"
	  			 	 				faxprocessed = Pref.faxprocessedfolder + "/" + File.basename(f)
									File.rename f, faxprocessed
	  			 	 			else
	  			 	 				@response = Fax.sendFax(f,params[File.basename(f)])
	      							@faxes<<@response
	      						end
	      				end
	  			 	 end

	  			 	#check what faxes are in the pending fax folder
    	 			#faxes that have a post parameter have been selected to be re sent
					 faxfolder = Pref.faxpendingfolder
	  			 	 @files = Dir.glob(faxfolder+"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
	  				
	  			 	 @files.each do |f|

	  			 	 	# find faxes to be sent
	  			 	 	if params[File.basename(f)] and params[File.basename(f)] != ""

	  			 	 			if params[File.basename(f)] == "trash"
	  			 	 				faxprocessed = Pref.faxprocessedfolder + "/" + File.basename(f)
									File.rename f, faxprocessed
	  			 	 			else
	  			 	 				@response = Fax.sendFax(f,params[File.basename(f)])
	      							@faxes<<@response
	      						end
	      				end
	  			 	 end


	  			 end
  			 end

  			 #check pending folder
	 		 faxfolder = Pref.faxpendingfolder
	     	 @pendingfiles = Dir.glob(faxfolder +"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
			 @pending=[]
			 username= Pref.faxusername
  		    password=Pref.decrypt_password(Pref.faxpassword)
  		    thisFax = Fax.new(username,password)
		 	 @pendingfiles.each do |pf|
		 	 	@pendingname =  File.basename(pf,".*")
		 	 	@pendingstatus = Fax.faxStatus(@pendingname,thisFax.access_token)
		 	 	if @pendingstatus["status"] == "sent"
		 	 		faxprocessed = Pref.faxprocessedfolder + "/" + File.basename(pf)
					File.rename pf, faxprocessed

		 	 	end
		 	 	@pending << [pf,@pendingstatus]
		 	 end

		 	





  			 # resample files as some may gave been moved
  			 faxfolder = Pref.faxfolder
  			 @files = Dir.glob(faxfolder+"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
  			 
  			 @files.take(10).each do |f|
  			 	unless File.exist?(::Rails.root.join('public','fax',File.basename(f, ".*")+ '.png'))
  			 		begin
						image=MiniMagick::Image.open(f)
						image.format("png", 0)
						image.resize("420x594")
						image.write(::Rails.root.join('public','fax',File.basename(f, ".*")+ '.png'))
					rescue
						# file couldn't be processed by MiniMagick so use default file which is oops.png
						FileUtils.cp Rails.root.join('public','fax','oops.png'), Rails.root.join('public','fax',File.basename(f, ".*") + '.png')
					end
				end
	  		end
  end

  def upload


   
  end

end
