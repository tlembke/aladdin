class FaxController < ApplicationController
  def index
  			# @files = Dir.glob("/Users/tlembke/Documents/*.pdf")

  			faxfolder = Pref.faxfolder
  			@files = Dir.glob(faxfolder+"/*.pdf").sort_by { |a| File.stat(a).mtime }.reverse
  			if request.post?
  				 @faxes=[]
  			 	 @files.each do |f|
  			 	 	# find faxes to be sent
  			 	 	if params[File.basename(f, ".pdf")] and params[File.basename(f, ".pdf")] != ""
  			 	 			@response = Fax.sendFax(f,params[File.basename(f, ".pdf")])
      						@faxes<<@response
      				end


  			 	 		
  			 	 	

  			 	 end
  			 end
  			 # resample files as some may gave been moved
  			 @files = Dir.glob(faxfolder+"/*.pdf").sort_by { |a| File.stat(a).mtime }.reverse
  			 
  			 @files.take(10).each do |f|
  			 	unless File.exist?(::Rails.root.join('public','fax',File.basename(f, ".pdf")+ '.png'))
  			 		
					image=MiniMagick::Image.open(f)
					image.format("png", 0)
					image.resize("420x594")
					

					image.write(::Rails.root.join('public','fax',File.basename(f, ".pdf")+ '.png'))
				end
	  		end
  end

end
