class NursinghomeController < ApplicationController
  require 'odbc'

  def index
    # assume date is today unless otherwise
    @username = session[:username]
    @password = session[:password]
    @user_id=session[:id]
    @name=session[:name]
    connect_array=connect()
      @error_code=connect_array[1]
      if (@error_code==0)
          dbh=connect_array[0]
          if params[:date]
            @date=params[:date]
          else
            @date=Date.today.to_s(:db)
          end
          nh_visit_array=get_nh_visit_dates(dbh,@user_id)
          @nh_visit_dates=nh_visit_array[0]
          @nh_visit_counts=nh_visit_array[1]
          #@nh_patients=get_nh_patients_names(dbh,@date,@user_id)
          dbh.disconnect
      else
          flash[:alert] = "Unable to connect to database. "+get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
      end



  end

  def show
  		@username = session[:username]
  		@password = session[:password]
        @user_id=session[:id]
        @name=session[:name]
		connect_array=connect()
  		@error_code=connect_array[1]
  		if (@error_code==0)
    		 	dbh=connect_array[0]
    		 	if params[:date]
    		 		@date=params[:date]
    		 	else
    		 		@date=Date.today.to_s(:db)
    		    end

    		 	@nh_patients=get_nh_patients(dbh,@date,@user_id)
				dbh.disconnect
  		else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
  		end
  	end


  	def get_nh_patients(dbh,date,doctor)
          
          sql = "SELECT Consult.PT_Id_Fk as PatientId, Plan,Diagnosis,History, Examination,MedicationListNotUsed,Consult.Id  from Consult, ConsultationProblem where ConsultationProblem.CNSLT_Id_Fk = Consult.Id and ConsultationProblem.ICPCCode = 'A64' and Consult.DoctorId = " + doctor.to_s + "  and Consult.ConsultDate = '" + date +"' "
          #sql = "SELECT PT_Id_Fk as PatientId, Id from Consult  where  DoctorId = " + doctor.to_s + "  and ConsultDate = '" + date +"' "
         
          puts sql
         

          sth = dbh.run(sql)
               
          nh_patients=[]
          sth.fetch_hash do |row|
          	@patient=Patient.get_patient(row['PatientId'].to_s,dbh)
          	row['MEDICATIONS']=Patient.medications(row['PatientId'].to_s,dbh)
          	row['PRESCRIPTION_HISTORY']=Patient.prescription_history(row['PatientId'].to_s,dbh,date)
          	# get med changes from Plan
	          tasks_array=extract_tasks(row['PLAN'])
	          row['TASKS']=tasks_array[0]
	          row['MEDCHANGES']=tasks_array[1]
	          row['NOTES']=tasks_array[2]
	          row['PLAN'] = tasks_array[3]
	          tests_array= get_tests(row['PLAN'])
	          row['TESTS']= tests_array[0]
	          row['PLAN']= tests_array[1]
          	  row['DOB']=@patient.dob
          	  row['FULLNAME']=@patient.fullname

            nh_patients << row
          end

          sth.drop



          return nh_patients

  end

  def get_nh_visit_dates(dbh,doctor)
     date=  2.weeks.ago.to_date
     date = date.to_s(:db)
      sql = "SELECT DISTINCT Consult.ConsultDate, COUNT(*) as 'num' from Consult, ConsultationProblem where ConsultationProblem.CNSLT_Id_Fk = Consult.Id and ConsultationProblem.ICPCCode = 'A64' and Consult.DoctorId = " + doctor.to_s + "  and Consult.ConsultDate > '" + date +"' ORDER BY ConsultDate DESC GROUP BY Consult.ConsultDate"
          #sql = "SELECT PT_Id_Fk as PatientId, Id from Consult  where  DoctorId = " + doctor.to_s + "  and ConsultDate = '" + date +"' "
      puts sql



       sth = dbh.run(sql)
               
          nh_visits_date=[]
          nh_visits_count=Hash.new
              sth.fetch_hash do |row|
              nh_visits_date << row['CONSULTDATE']
              nh_visits_count[row['CONSULTDATE']]=row['num']
          end

          sth.drop
          return nh_visits_date,nh_visits_count
         

  end

end
