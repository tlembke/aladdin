class ResultsController < ApplicationController
  def index
  	  	@username = session[:username]
  		@password = session[:password]
        @id=session[:id]
        @name=session[:name]

  		 connect_array=connect()
  		 @error_code=connect_array[1]
  		 if (@error_code==0)
    		 	dbh=connect_array[0]
    		 	@id=params[:patient_id]
    		 	@patient=get_patient(@id,dbh)
  				@patient.results=get_results(@id,dbh,limit=50)
				dbh.disconnect
  		 else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  controller: "genie", action: "login"
  		 end
  end




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
    		 	@patient=get_patient(@id,dbh)
  				@result=get_result(params[:id],dbh)
  				
				dbh.disconnect
  		 else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  controller: "genie", action: "login"
  		 end
  end

  private

    def get_results(patient,dbh, limit=50)

        sql = "SELECT Test, CollectionDate, HL7Type, Id FROM  DownloadedResult where PT_Id_FK = " + patient.to_s + " ORDER BY CollectionDate DESC LIMIT " +limit.to_s
 
          puts sql
         

          sth = dbh.run(sql)
               
          results=[]
          sth.fetch_hash do |row|

            results << row
          end





          
          

         
          sth.drop
          
          return results

  end 

  def get_result(id,dbh)

        sql = "SELECT Test, CollectionDate, HL7Type, Result FROM  DownloadedResult where Id =  " + id
 
          puts sql
         

          sth = dbh.run(sql)
               
          theresult=[]
          sth.fetch_hash do |row|

            	theresult =  row
          end




          
          

         
          sth.drop
          
          return theresult

  end 

end


