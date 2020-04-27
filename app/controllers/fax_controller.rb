class FaxController < ApplicationController
  def index
  			# @files = Dir.glob("/Users/tlembke/Documents/*.pdf")

  			
  			faxfolder = Pref.faxfolder
  			if request.post?
  		

  				if params[:commit] == "Upload file"
		  		 	
				    uploaded_io = params[:fax]
				    File.open(faxfolder +"/" + uploaded_io.original_filename, 'wb') do |file|
		  				file.write(uploaded_io.read)
					end

    	 		else


    	 			 @files = Dir.glob(faxfolder+"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
	  				 @faxes=[]
	  			 	 @files.each do |f|

	  			 	 	# find faxes to be sent
	  			 	 	if params[File.basename(f)] and params[File.basename(f)] != ""
	  			 	 			@response = Fax.sendFax(f,params[File.basename(f)])
	      						@faxes<<@response
	      				end
	  			 	 end
	  			 end
  			 end
  			 # resample files as some may gave been moved
  			 @files = Dir.glob(faxfolder+"/*.*").sort_by { |a| File.stat(a).mtime }.reverse
  			 
  			 @files.take(10).each do |f|
  			 	unless File.exist?(::Rails.root.join('public','fax',File.basename(f, ".*")+ '.png'))

					image=MiniMagick::Image.open(f)
					image.format("png", 0)
					image.resize("420x594")
					

					image.write(::Rails.root.join('public','fax',File.basename(f, ".*")+ '.png'))
				end
	  		end
  end

  def upload


   
  end

end
