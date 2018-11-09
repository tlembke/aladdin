class AppointmentsController < ApplicationController
  def index
  	 # get appointments
  	 @username = session[:username]
  	 @password = session[:password]
     @id=session[:id]
     @name=session[:name]

  	 connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
    	  dbh=connect_array[0]
    	  @theStartDate = Date.today
        @preventPast = false
    	  if params[:date]              
              	@theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
          end
    	  
    	  @noDays=7

		  theFinishDate = @theStartDate + @noDays.days
          @appointments=get_appointments(dbh,@id,@theStartDate,@noDays)
          dbh.disconnect
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
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

          # Seen today
          @appointments=get_day_appointmnets(dbh,@id)
          dbh.disconnect
     else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
  	 end
  end
end

def get_appointments(dbh,doctor,theStartDate = Date.today,noDays = 7)

		  theFinishDate = theStartDate + 5.days
          sql = "SELECT StartDate, StartTime, Reason, Name, Pt_ID_FK as patient_id FROM Appt WHERE ProviderID =  " + doctor.to_s + " AND StartDate >= '" + theStartDate.to_s(:db) + "' AND  StartDate <= '"+ theFinishDate.to_s(:db) + "' ORDER BY StartDate, StartTime"
          puts sql
         

          sth = dbh.run(sql)
               
          appointments=Hash.new
          
          sth.fetch_hash do |row|
          	datekey = row['STARTDATE'].to_date.strftime("%Y-%m-%d")
          	timekey= row['STARTTIME'].to_time.strftime("%l:%M").strip

           unless appointments.key?(datekey)
           		appointments[datekey]=Hash.new
           end
           unless appointments[datekey].key?(timekey)
           		appointments[datekey][timekey]=Hash.new
           end
          	appointments[datekey][timekey]['reason']=row['REASON']
          	appointments[datekey][timekey]['name']=row['NAME']
            appointments[datekey][timekey]['patient_id']=row['patient_id']
          end

          sth.drop



          return appointments
end
