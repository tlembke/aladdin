class LettersController < ApplicationController
  def show
  	  	@username = session[:username]
  		@password = session[:password]
        @id=session[:id]
        @name=session[:name]

  		 connect_array=connect()
  		 @error_code=connect_array[1]
  		 if (@error_code==0)
    		 	dbh=connect_array[0]
    		 	@id=params[:patient_id]
    		 	letter_id=params[:id]
    		 	@patient=get_patient(@id,dbh)
    		 	sql = "SELECT Id, Sender, LetterDate, LetterContent_, LetterContentText, LetterType FROM IncomingLetter WHERE Id = " + letter_id.to_s
          		puts sql 
			    sth = dbh.run(sql)
   				
          		sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            			@letter = row

              	end

          		sth.drop

          		# is there a blob with this letter

          		sql = "SELECT RecordBlob, RecordType, DisplayType FROM PatientBlob WHERE LTRIN_Id_Fk = " + @letter['ID'].to_s
          		puts sql 
			    sth = dbh.run(sql)
   				@blob=""
          		sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            			@blob = row

              	end


  				
  				
				dbh.disconnect
  		 else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  controller: "genie", action: "login"
  		 end
  end

  def view

  	  	@username = session[:username]
  		@password = session[:password]
        @id=session[:id]
        @name=session[:name]

  		 connect_array=connect()
  		 @error_code=connect_array[1]
  		 if (@error_code==0)
    		 	dbh=connect_array[0]
    		 	@id=params[:patient_id]
    		 	letter_id=params[:id]
    		 	@patient=get_patient(@id,dbh)
    		 	 sql = "SELECT RealName, Description, ImageDate FROM Graphic WHERE Id = " + letter_id.to_s 
          		puts sql 
    			sth = dbh.run(sql)
   				
          		sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            			@letter = row

              	end

          		sth.drop
		
				dbh.disconnect

				# move file
				fileaddress= File.join(Pref.imagesfolder,@patient.surname[0],@patient.surname+@patient.firstname[0]+@patient.id.to_s,@letter['REALNAME'])
				filenewaddress = "#{Rails.root}/public/tmp/" + @letter['REALNAME']
				
				FileUtils.cp fileaddress, filenewaddress

				mime_type = Rack::Mime.mime_type(File.extname(filenewaddress))

				filename = @patient.surname+"_"+@patient.firstname[0]+"_"+@letter['REALNAME']
	




				send_file(filenewaddress, :filename => filename, :disposition => 'inline', :type => mime_type)

  		 else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  controller: "genie", action: "login"
  		 end
  		
  end


end
