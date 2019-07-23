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
          @appointments=get_day_appointments(dbh,@id)
          dbh.disconnect
     else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
  	 end
  end


def examen
     # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]
     # @id=89 #Janeen
     # @id=72 #Helen
     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
        @providerType = get_user_type(dbh,@id)
        @theStartDate = Date.today
        @preventPast = false
        @noDays = 1
        if @providerType == 2

          if params[:date]              
                  @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
          end

          @unlinkedPath, @pathDate = getUnlinkedPath(dbh,@username)
          @unlinkedLetters, @letterDate = getUnlinkedLetters(dbh,@username)
          @scans, @scanDate = getScans(dbh,@username)
          @tasks = getTasks(dbh,@username)
        
          @apptsFree = getThirdAvailable(dbh,@id,startDate=Date.today,numberAppts=3,finishDate=Date.today + 8.weeks)
        end
        dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end


     
  end

  def getUnlinkedPath(dbh,doctorName)
          surname = doctorName.split.last
          sql = "SELECT Count(Id) FROM DownloadedResult WHERE PT_Id_Fk = 0 AND Addressee LIKE  '%" + surname +"'"
          puts sql
         

          sth = dbh.run(sql)
          row= sth.fetch_first
          row == nil or row[0] == nil ? unlinkedPath = 0 : unlinkedPath = row[0]

          sth.drop



          sql2 = "SELECT CollectionDate FROM DownloadedResult WHERE PT_Id_Fk = 0 AND Addressee LIKE  '%" + surname +"' ORDER BY CollectionDate ASC"
          puts sql2
         

          sth2 = dbh.run(sql2)
          row2= sth2.fetch_first
          if row2 
            collectionDate = row2[0]
          else
            collectionDate = Date.today
          end
          sth2.drop
          return unlinkedPath, collectionDate
  end

  def getUnlinkedLetters(dbh,doctorName)
          surname = doctorName.split.last
          sql = "SELECT Count(Id) FROM IncomingLetter WHERE PT_Id_Fk = 0 AND Addressee LIKE  '%" + surname +"'"
          puts sql
         

          sth = dbh.run(sql)
          row= sth.fetch_first
          row == nil or row[0] == nil ? unlinked = 0 : unlinked = row[0]

          sth.drop


          sql2 = "SELECT LetterDate FROM IncomingLetter WHERE PT_Id_Fk = 0 AND Addressee LIKE  '%" + surname +"' ORDER BY LetterDate ASC"
          puts sql2
         

          sth2 = dbh.run(sql2)
          row2= sth2.fetch_first
          if row2 
            letterDate = row2[0]
          else
            letterDate = Date.today
          end
          sth2.drop

          return unlinked, letterDate
  end

  def getScans(dbh,doctorName)
          surname = doctorName.split.last
          sql = "SELECT Count(Id) FROM Graphic WHERE Reviewed = False AND ReviewBy LIKE  '%" + surname +"'"
          puts sql
         

          sth = dbh.run(sql)
          row= sth.fetch_first
        
          row == nil or row[0] == nil ? unlinked = 0 : unlinked= row[0]
          sth.drop

          sql2 = "SELECT ImageDate FROM Graphic WHERE Reviewed = False AND ReviewBy LIKE  '%" + surname +"' ORDER BY ImageDate ASC"
          puts sql2
         

          sth2 = dbh.run(sql2)
          row2= sth2.fetch_first
          if row2 
            imageDate = row2[0]
          else
            imageDate = Date.today
          end
          sth2.drop

          return unlinked, imageDate
  end
  def getTasks(dbh,doctorName)
          surname = doctorName.split.last
          sql = "SELECT TaskDate, Task, Note, UrgentFg, Patient FROM Task WHERE Completed = False AND TaskDate <= '" + Date.today.to_s(:db) + "' AND TaskFor LIKE  '%" + surname +"' ORDER BY TaskDate DESC"
          puts sql
          
          tasks=[]
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
              task= { date: row['TASKDATE'], title: row['TASK'], note: row['NOTE'], patient: row['PATIENT'], urgent: row['URGENTFG']}
              tasks<< task
          end
        
          sth.drop





          return tasks


  end

    


  def patient_audit
         # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]
     # @id=89
     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
        

    
        @theStartDate = Date.today
        @preventPast = false
     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)


   
   
     elsif params[:day] != "false" and params[:month] != "false" and params[:year] != "false"

                @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
     else@providerType = get_user_type(dbh,@id)
        @theStartDate=Date.today
    end
        
        @noDays=1
          @prov=@id
          unless @providerType == 2
            @prov = 89
          end

      
          @appts,@totalCount,@blankCount,@noreasonCount =get_days_appts(dbh,@id,@prov,@theStartDate)
          #@appt_ids=@appts.map {|x| x.values[9]}
          dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     render partial: "patient_audit"

  end

    def prepare
         # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
        @providerType = get_user_type(dbh,@id)


    
        @theStartDate = Date.today
        currentTime = Time.now
        if currentTime.hour > 16
            @theStartDate = @theStartDate + 1
            @theStartDate = @theStartDate + 2 if @theStartDate.saturday?
            @theStartDate = @theStartDate + 1 if @theStartDate.sunday?
        end
 
        @preventPast = false

     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)


   
   
     elsif params[:day] != "false" and params[:day] != nil and params[:month] != "false" and params[:month] != nil and params[:year] != "false" and params[:year] != nil

                @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)

    end
        
        @noDays=1
        @noConsults = 3

      
          @appointments =get_last_appts(dbh,@id,@theStartDate,@noConsults)
          #@allappts = get_appointments(dbh,@id,@theStartDate,1)
          #@appt_ids=@appts.map {|x| x.values[9]}
          dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     # render partial: "prepare"

  end


def get_appointments(dbh,doctor,theStartDate = Date.today,noDays = 7)

		  theFinishDate = theStartDate + 5.days
          sql = "SELECT StartDate, StartTime, Reason, Name, ApptDuration, Pt_ID_FK as patient_id FROM Appt WHERE ProviderID =  " + doctor.to_s + " AND StartDate >= '" + theStartDate.to_s(:db) + "' AND  StartDate <= '"+ theFinishDate.to_s(:db) + "' ORDER BY StartDate, StartTime"
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
              if row['APPTDURATION'] == 1800
                # add 15 mins
                newtime = row['STARTTIME'].to_time + 15.minutes
                timekey = newtime.strftime("%l:%M").strip
                appointments[datekey][timekey]=Hash.new
                appointments[datekey][timekey]['reason']=row['REASON']
                appointments[datekey][timekey]['name']=row['NAME']
                appointments[datekey][timekey]['patient_id']=row['patient_id']
              end

          end

          sth.drop



          return appointments
end

 def get_days_appts(dbh,doctor,room,theStartDate = Date.today )
          blankCount=0
          totalCount=0
          noreasonCount=0
          theDay=theStartDate.to_s(:db)
          
          sql = "SELECT Name, Note,  Reason, StartDate, StartTime, Status, PT_Id_Fk FROM Appt WHERE ProviderID = " + room.to_s + " and StartDate = '" + theDay + "' and PT_Id_FK <> 0 ORDER BY StartTime"
          puts sql
         

          sth = dbh.run(sql)



               
          appts=[]

          sth.fetch_hash do |row|

            
      
            row['CLINICAL'],row['PLAN'],row['PROBLEMS']= get_consult_plan(dbh,row['PT_ID_FK'],doctor,theDay)
            
            
            appts << row
            if row['CLINICAL'] == ""
              blankCount = blankCount + 1
            end
            totalCount = totalCount + 1
            if row['PROBLEMS'].length ==0
                noreasonCount=noreasonCount + 1
            end
         


          end

          sth.drop



          return appts, totalCount, blankCount, noreasonCount

  end

   def get_last_appts(dbh,doctor,theStartDate = Date.today, noConsults = 1 )

          theDay=theStartDate.to_s(:db)
          
          sql = "SELECT Name, Note,  Reason, StartDate, StartTime, Status, PT_Id_Fk FROM Appt WHERE ProviderID = " + doctor.to_s + " and StartDate  = '" + theDay + "' ORDER BY StartTime"
          puts sql
         

          sth = dbh.run(sql)



               
          appts=[]

          sth.fetch_hash do |row|
            
          if row['PT_ID_FK'] > 0
            row['LASTCONSULTS'] = get_last_consults(dbh,row['PT_ID_FK'],theDay,noConsults)
          else
            row['LASTCONSULTS'] = []
          end
            
            
            appts << row

         


          end

          sth.drop



          return appts

  end

    def get_consult_plan(dbh,patient,provider,theDate)
            
            sql = "SELECT History, Examination, Diagnosis, Plan, Id FROM Consult WHERE PT_Id_FK = " + patient.to_s + " and ConsultDate = '" + theDate + "' and DoctorID = " + provider.to_s
          
            puts sql
            planText=""
            clinicalText=""
            problems=[]
            sth = dbh.run(sql)
             sth.fetch do |row|
              clinicalText= row[0] +row[1] + row[2]
              planText =  row[3]
              problems = get_real_problems(dbh, row[4])

            end

            sth.drop

          


            return clinicalText, planText, problems


 end

     def get_last_consults(dbh,patient,theDate, noConsults=2)
            sql = "SELECT History, Examination, Diagnosis, Plan, Id, ConsultDate, DoctorName FROM Consult WHERE PT_Id_FK = " + patient.to_s + " and ConsultDate < '" + theDate + "' ORDER BY ConsultDate DESC LIMIT " + noConsults.to_s
          
            puts sql
            
            consults=[]
            sth = dbh.run(sql)
             sth.fetch do |row|
              problems=[]
              consult=Hash.new

              consult['clinicalText']= row[0] +row[1] + row[2] + row[3]
              consult['problems'] = get_real_problems(dbh, row[4])
              consult['date'] = row[5]
              consult['provider'] = row[6]
              consults << consult



            end

            sth.drop

          


            return consults


 end

   def get_real_problems(dbh,consult)
    # this gets the reason for consulation rather than medical history
          sql = "SELECT Problem FROM ConsultationProblem WHERE CNSLT_Id_FK = " + consult.to_s + " ORDER BY IsPrimaryProblem DESC"
          puts sql
          sth = dbh.run(sql)      
          problems=[]
          sth.fetch do |row|
            unless row[0] == "Pathology" or row[0] == "Prescription(s)"
              problems<<row[0]
            end
          end
          sth.drop
           
          return problems

  end

end
