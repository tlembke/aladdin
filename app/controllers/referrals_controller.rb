class ReferralsController < ApplicationController
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
    		     sql = "SELECT AddresseeName, LetterDate, ReferralContent_ FROM OutgoingLetter WHERE Id = " + letter_id.to_s
				puts sql 
			    sth = dbh.run(sql)
   				
          		sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            			@letter = row

              	end



          

          		sth.drop
          
     
  
      


  				
  				
				dbh.disconnect
  		 else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  controller: "genie", action: "login"
  		 end
  end
end
