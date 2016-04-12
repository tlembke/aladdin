class PatientController < ApplicationController
  require 'odbc'


  def index
  		@username = session[:username]
  		@password = session[:password]
        @id=session[:id]
        @name=session[:name]

  		 	connect_array=connect()
  		 	@error_code=connect_array[1]
  		 	if (@error_code==0)
    		 	dbh=connect_array[0]

          # Seen today
          @seen_patients=get_seen_patients(dbh)
          # Get open patients ie Status = 4
          @open_patients=get_open_patients(dbh)


          # Search 
          @patients_search=[]
          if request.post?
              surname_text=""
              if params[:Surname] and params[:Surname]!=""
                surname = params[:Surname] + "%"
                  surname_text= "Surname LIKE '%s'" % surname
              end
              firstname_text=""
              if params[:FirstName] and params[:FirstName]!=""
                   firstname = params[:FirstName] + "%"
                  firstname_text="(FirstName LIKE '%s'" % firstname
                  firstname_text=firstname_text + " OR KnownAs LIKE '%s'" % firstname
                  firstname_text+=")"
              end
              if surname_text!="" and firstname_text!=""
                surname_text=surname_text + " AND "
              end
              where_clause = surname_text + firstname_text
              puts "Where is " + where_clause
              if where_clause!=""
                sql = "SELECT Surname,FirstName,LastSeenDate,id FROM Patient WHERE " + where_clause + "ORDER BY Surname"
                puts sql

                sth = dbh.run(sql)
           
                @patients_search=[]
                sth.fetch_hash do |row|
                  #patient_h = Hash["Surname" => row[0], "FirstName" => row[1],"id"=>row[3]]
                  @patients_search<< row
                end
                sth.drop
              end
          end

          





  			  dbh.disconnect
  			else
  				flash[:alert] = "Unable to connect to database. "+get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
  			end
  	end


	def show

		@id=params[:id]
    connect_array=connect()
    @error_code=connect_array[1]
    if (@error_code==0)
          dbh=connect_array[0]
        # Get info about this patient
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB FROM Patient WHERE id = "+@id
         puts sql
         

          sth = dbh.run(sql)
               
          sth.fetch_hash do |row|
            @patient = row
          end

          sth.drop

          # Get last consult details
          sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis,Id FROM Consult WHERE PT_Id_FK = " + @id + " ORDER BY ConsultDate DESC LIMIT 1"
          puts sql
          sth = dbh.run(sql)
           sth.fetch_hash do |row|
            @consult = row
          end
          sth.drop
          
          @problems=get_problems(dbh,@consult['ID'])

          if (@consult['DIAGNOSIS'] == "")
            if @problems.count>0
                @consult['DIAGNOSIS']=@problems[0]
            else
                @consult['DIAGNOSIS']="Consultation"
            end
          end
          tasks_array=extract_tasks(@consult['PLAN'])
          @tasks=tasks_array[0]
          @meds=tasks_array[1]
          @notes=tasks_array[2]
          @plan = tasks_array[3]
          tests_array= get_tests(@plan)
          @tests= tests_array[0]
          @plan= tests_array[1]
          @medications = get_medications(@id,dbh)
          @appointments = get_appointments(@id,dbh)
          @measures = get_measures(@id,dbh)
          

    else
          # lost connection to database
          flash[:notice]=error_msg
          redirect_to  action: "login"
    end

    if params[:print]
          render :print
    end

	end

  def get_medications(patient,dbh)
          sql = "SELECT Medication, Dose, Frequency, Instructions, Category, CreationDate FROM Prescription WHERE PT_Id_FK = " + patient.to_s + " ORDER BY Medication"
          puts sql
         

          sth = dbh.run(sql)
               
          medications=[]
          sth.fetch_hash do |row|
            row["INSTRUCTIONS"]=expand_instruction(row["INSTRUCTIONS"])
            row["FREQUENCY"]=expand_instruction(row["FREQUENCY"])
            medications << row
          end

          sth.drop



          return medications
  end

    def get_appointments(patient,dbh)
          sql = "SELECT StartDate, StartTime, ProviderName,Reason FROM Appt WHERE PT_Id_FK = " + patient.to_s + " AND StartDate > '" + Date.today.to_s(:db) + "' ORDER BY StartDate"
          puts sql
         

          sth = dbh.run(sql)
               
          appointments=[]
          sth.fetch_hash do |row|
            appointments << row
          end

          sth.drop



          return appointments
  end

  def get_open_patients(dbh)
          sql = "SELECT  PT_Id_FK, Surname, FirstName FROM Appt,Patient WHERE Appt.Status = 4  AND Appt.StartDate = '" + Date.today.to_s(:db) + "' and Appt.PT_Id_FK = Patient.Id"
          puts sql
         

          sth = dbh.run(sql)
               
          patients=[]
          sth.fetch_hash do |row|
            patients << row
          end

          sth.drop



          return patients

  end
    def get_seen_patients(dbh)
          today=Date.today.to_s(:db)
          
          sql = "SELECT Surname,FirstName,LastSeenDate,Id FROM Patient where LastSeenDate = '"+today+"' and LastSeenBy= '"+session[:username]+"'"
 
          puts sql
         

          sth = dbh.run(sql)
               
          patients=[]
          sth.fetch_hash do |row|
            patients << row
          end

          sth.drop



          return patients

  end

    def get_macros
    m = HashWithIndifferentAccess.new #=> {}
    m['b'] = "Blood test"
    m['bf'] = "Blood test (fasting)"
    m['p'] = "Phone me"
    m['r'] = "Make an appointment with me"
    m['a'] = "Make an appointment"
    m['m'] = ""
    m['t'] = ""
    m['n'] = ""

    return m

  end

  def extract_tasks(plan)
    # plan has \r instead of \m
    plans=plan.split("\r")
    plan=plans.join("\n")
    macros=get_macros
    keys=macros.keys
    # see if there are any matches for each key and extract them from text
    meds=[]
    tasks=[]
    notes=[]
    keys.each do |short|
      re="^@"+short+"(.*)"
      while (task1=plan.match re) do
        if task1
          # ok, we have a task
          task=macros[short]+task1[1]
          task=task.strip
          task[0] = task[0,1].upcase
          task=expand_time(task)

          if short== "n"
            notes<< task
          elsif short== "m"
            meds<< task
          else
            tasks<< task
          end
          # and remove task from plan
          plan=plan.sub task1[0],'' 
          plan=plan.strip
        end
      end
    end
    return tasks,meds,notes,plan
  end

  def expand_time(task)
    orig_task=task
    e = HashWithIndifferentAccess.new #=> {}
    e['d'] = "day"
    e['m'] = "month"
    e['w'] = "week"
    e['y'] = "year"
    re = "(\d)\s?(\S)\s*"
    task1=task.match  /(\d)\s?(\S)\b+/
    if task1
        number=task1[1].to_i
        span=task1[2]
        next_date=""
        if e[task1[2]]
          span = e[task1[2]]
          multiplier=1
          next_date=Date.today
          case task1[2]
          when "m"
            next_date=next_date+number.months
          when "w"
            next_date=next_date+number.weeks
          when "d"
            next_date=next_date+number.days
          when "y"
            next_date=next_date+number.years
          end
          if(next_date <= Date.today + 1.week)
            next_date=" (next " + next_date.strftime("%a")+")"
          else
            next_date=" (~"+next_date.strftime("%a, %b %d")+")"
          end
        end
        if number > 1
          span=span+"s"
        end
        task=task.sub task1[0],task1[1]+' '+span.strip+' '
        task = task + next_date

    end
    return task
  end

  def get_tests(plan)
    tests=[]
    while (tests_match= plan.match /^\^(.*)\^:\s*(.*)/) do
        test=[]
        test[0]=tests_match[1]
        test[1]=tests_match[2]
        tests<<test
        # now remove that test from plan
        plan=plan.sub tests_match[0],'' 
    end

 
    return tests,plan
  end

  def expand_instruction(instruction)
    e = HashWithIndifferentAccess.new #=> {}
    e['mane'] = "in the morning"
    e['nocet'] = "at night"
    e['tds'] = "three times a day"
    e['bd'] = "twice a day"
    e['prn'] = "as required"
    keys=e.keys
    keys.each do |short|
      instruction=instruction.sub short, e[short]
    end
    return instruction
  end

  def get_problems(dbh,consult)
          sql = "SELECT Problem FROM ConsultationProblem WHERE CNSLT_Id_FK = " + consult.to_s + " ORDER BY IsPrimaryProblem DESC"
          puts sql
          sth = dbh.run(sql)      
          problems=[]
          sth.fetch do |row|
            problems<<row[0]
          end
          sth.drop
          return problems
  end



  def get_measures(patient,dbh)
          today=Date.today.to_s(:db)

          sql = "SELECT Systolic,Diastolic,Weight,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " and MeasurementDate = '"+today+"'"
 
          puts sql
         

          sth = dbh.run(sql)
               
          measures=Hash.new
          sth.fetch_hash do |row|
            measures=row
          end

         

         
          sth.drop
          return measures
  end

end
