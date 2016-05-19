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
          @patient=get_patient(@id,dbh)


          # Deafult Get last consult details
          # Unless otherwise selected
          if params[:consult_id]
              sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis,Id FROM Consult WHERE Id = " + params[:consult_id]
          else
              sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis,Id FROM Consult WHERE PT_Id_FK = " + @id + " ORDER BY ConsultDate DESC LIMIT 1"
          end
          puts sql
          sth = dbh.run(sql)
           sth.fetch_hash do |row|
            @consult = row
          end
          sth.drop

          # Get other recent consults as well
          @recent_consults=[]
          sql = "SELECT ConsultDate, DoctorName, Id FROM Consult WHERE PT_Id_FK = " + @id + " ORDER BY ConsultDate DESC LIMIT 5"
          puts sql
          sth = dbh.run(sql)
           sth.fetch_hash do |row|
            @recent_consults << row
          end
          sth.drop
          
          @problems=get_problems(dbh,@consult['ID'])

          careplan=false
          if ! params[:consult]
            if params[:careplan]
                careplan=true
            end
            @problems.each do |problem|
                if problem.include? ("Plan")
                   careplan=true
                end
            end
          end

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
          @current_problems = get_current_problems(@id,dbh)
          history_array = get_history(@id,dbh)
          @procedures=history_array[0]
          @events=history_array[1]
          @allergies=get_allergies(@id,dbh)
          @careteam=get_careteam(@id,dbh)

          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

    if params[:print]
          render :print
    end

 
	end


  def careplan
    @id=params[:id]
    connect_array=connect()
    @error_code=connect_array[1]
    if (@error_code==0)
          dbh=connect_array[0]
        # Get info about this patient
          @patient=get_patient(@id,dbh)
          #tasks_array=extract_tasks(@consult['PLAN'])
          #@tasks=tasks_array[0]
          #@meds=tasks_array[1]
          #@notes=tasks_array[2]
          #@plan = tasks_array[3]
          #tests_array= get_tests(@plan)
          #@tests= tests_array[0]
          #@plan= tests_array[1]
          @medications = get_medications(@id,dbh)
          @appointments = get_appointments(@id,dbh)
          # @measures = get_measures(@id,dbh)
          @current_problems = get_current_problems(@id,dbh)
          history_array = get_history(@id,dbh)
          @procedures=history_array[0]
          @events=history_array[1]
          @allergies=get_allergies(@id,dbh)
          @careteam=get_careteam(@id,dbh)
          bpsweights=get_bps(@id,dbh,50)
          @bps=bpsweights[0]
          @weights=bpsweights[1]
          @lipids=get_lipids(@id,dbh,50)
          @all_measures=get_all_measurements(@id,dbh,50)
          @tracked_items=[721,723,732,2517,2521,701,703,900]
          @item_numbers=get_item_numbers(@id,dbh,@tracked_items)
          
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

    if params[:print]
          @print = true
          render :careplanprint
    end


  end

  def import_goals
        @masters=Goal.where(patient_id: 0).where.not(master_id: nil).order("master_id ASC") 
        @id=params[:id]
        if request.post?
            error_msg=""
            @masters.each do |goal|
              if params[:goal][goal.id.to_s]=="1"
                 # need to create new patient goal with parent master
                 condition_selected=params[:goal][:master][goal.master_id.to_s]
                 if condition_selected == "" and goal.master.id!=1
                          byebug
                          error_msg += "Goals cound not be imported from section " + goal.master.name + ". Patient condition was not selected.<br>"
                 else
                        newgoal=goal.dup
                        newgoal.patient_id=@id
                        newgoal.parent=goal.id
                        if goal.master_id==1
                              newgoal.condition_id=0
                        else 
                              newgoal.condition_id=params[:goal][:master][goal.master_id.to_s]
                        end
                         newgoal.save
                      
                 end
              end
   
          end
          if error_msg==""
                flash[:notice]="Goals imported"
                redirect_to  careplan_patient_path(:id => @id)
          else
                flash[:notice]=error_msg.html_safe
          end
      end

      connect_array=connect()
      dbh=connect_array[0]
      
      current_problems = get_current_problems(@id,dbh)
      
      @cond_select = current_problems.map{ |problem| [problem["PROBLEM"], problem["ID"]] }
      @cond_select.unshift ["Import to...",""]
      

      dbh.disconnect
  end

  private


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



  def get_patient(patient,dbh)
            # Get info about this patient
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, Scratchpad, FamilyHistory FROM Patient WHERE id = "+patient       
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            @patient=Patient.new(id: @id, surname: row['SURNAME'], firstname: row['FIRSTNAME'], fullname: row['FULLNAME'], lastseendate: row['LASTSEENDATE'], lastseenby: row['LASTSEENBY'], addressline1: row['ADDRESSLINE1'], addressline2: row['ADDRESSLINE2'],suburb: row['SUBURB'],dob: row['DOB'], age: row['AGE'], sex: row['SEX'], scratchpad: row['SCRATCHPAD'], social: row['FAMILYHISTORY'])
          end
          sth.drop
          return @patient
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

    def get_item_numbers(patient,dbh,tracked_items)
          theSearch = tracked_items.join("' OR ItemNum = '")


          sql = "SELECT  ServiceDate,ItemNum from Sale  where PT_Id_FK = " + patient + " and (ItemNum = '"+theSearch + "') ORDER BY ServiceDate DESC"
          puts sql
          sth = dbh.run(sql)
               
          item_numbers=Hash.new
          sth.fetch_hash do |row|
            if ! item_numbers[row['ITEMNUM']]
              item_numbers[row['ITEMNUM']] = row['SERVICEDATE'].to_date
            end
          end

          
          if item_numbers['2521']
              if item_numbers['2517']
                 if item_numbers['2521'] > item_numbers['2517']
                    item_numbers['2517'] = item_numbers['2521']
                 end
              else
                 item_numbers['2517'] = item_numbers['2521']
              end
          end
          sth.drop

          return item_numbers

  end



  def get_measures(patient,dbh)
          today=Date.today.to_s(:db)
          consult_date= @consult['CONSULTDATE'].to_date
          consult_date=consult_date.to_s(:db)

          sql = "SELECT Systolic,Diastolic,Weight,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " and MeasurementDate = '"+ consult_date +"'"
 
          puts sql
         

          sth = dbh.run(sql)
               
          measures=Hash.new
          sth.fetch_hash do |row|
            measures=row
          end

         

         
          sth.drop
          return measures
  end

  def get_bps(patient,dbh,number)


          sql = "SELECT Systolic,Diastolic,Weight,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " ORDER BY MeasurementDate Desc LIMIT "+ number.to_s
 
          puts sql
         

          sth = dbh.run(sql)
               


          # systolic BP is returned as string - drats
          bps=[]
          weights=[]
          sth.fetch_hash do |row|
            row['SYSTOLIC']=row['SYSTOLIC'].to_i
            row['DIASTOLIC']=row['DIASTOLIC'].to_i
            
            if row['SYSTOLIC'] > 0
                bps << row
            end

            if row['WEIGHT'] > 0
                weights << row
            end
          end
         

         
          sth.drop

          return [bps,weights]


  end

  def get_all_measurements(patient,dbh,number)
      sql = "SELECT ACR,BMI,BSL,Creatinine,FEV1,FVC,ACR,BSL,Creatinine,GFR,HbA1C,HeadCircumference,HeartRate,Height,Hip,GasTransfer,Microalbuminuria,Neck,Potassium,PSA,Waist,WaistHipRatio,Weight,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " ORDER BY MeasurementDate Desc LIMIT "+ number.to_s
      puts sql
      sth = dbh.run(sql)
      all_measures=[]
      sth.fetch_hash do |row|
          row.delete_if {|key, value| value == 0 or value =="0"}
          all_measures << row if row.count > 1
      end
      sth.drop
      return all_measures
  end

  def get_lipids(patient,dbh,number)


          sql = "SELECT Cholesterol,HDL,LDL,Triglycerides,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " and Cholesterol > 0 ORDER BY MeasurementDate Desc LIMIT "+ number.to_s
 
          puts sql
         

          sth = dbh.run(sql)
               


          # systolic BP is returned as string - drats
          lipids=[]
          sth.fetch_hash do |row|
                row.delete_if {|key, value| value == 0 }
 
                lipids << row
 
          end
         

         
          sth.drop

          return lipids
  end

  def get_current_problems(patient,dbh)

        sql = "SELECT Problem,Note,Confidential,TermCode,ICPCCode,Id,DiagnosisDate FROM CurrentProblem where PT_Id_FK = " + patient
 
          puts sql
         

          sth = dbh.run(sql)
               
          current_problems=[]
          sth.fetch_hash do |row|

            # Should we update local model here instead
            current_problems<< row
          end

         

         
          sth.drop
          return current_problems

  end

  def get_allergies(patient,dbh)

        sql = "SELECT Allergy,Detail,ReactionType FROM Allergy where PT_Id_FK = " + patient
 
          puts sql
         

          sth = dbh.run(sql)
               
          allergies=[]
          sth.fetch_hash do |row|
            allergies<< row
          end

         

         
          sth.drop
          return allergies

  end  

    def get_history(patient,dbh)
          sql = "SELECT History,Note, Procedure,TermCode,ICPCCode,CreationDate FROM PastHistory where Confidential = false AND PT_Id_FK = " + patient 
          puts sql
          sth = dbh.run(sql)
          procedures=[]
          events=[]
          sth.fetch_hash do |row|

            if row["PROCEDURE"]=="true"
              procedures<< row
            else
              events << row
            end
          end
          sth.drop
          return  [procedures,events]
  end


  def get_careteam(patient,dbh)
          sql = "SELECT ProviderName, ProviderPhone,ProviderType, AB_Id_Fk FROM InterestedParty where PT_Id_FK = " + patient
          puts sql
          sth = dbh.run(sql)
          careteam=[]
          sth.fetch_hash do |row|
              member = Member.find_or_create_by(patient_id: patient, genie_id: row['AB_ID_FK'])
              row['member']=member
              careteam << row
          end
          sth.drop
          return  careteam
  end
end
