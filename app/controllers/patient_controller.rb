class PatientController < ApplicationController
  require 'odbc'
  require 'zip'


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
              sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis, History, Examination, Id FROM Consult WHERE Id = " + params[:consult_id]
          else
              sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis,History, Examination, Id FROM Consult WHERE PT_Id_FK = " + @id + " ORDER BY ConsultDate DESC LIMIT 1"
          end
          puts sql
          sth = dbh.run(sql)
           sth.fetch_hash do |row|
            row['CONSULTDATE']=row['CONSULTDATE'].to_date
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
          @phonetime = get_phonetime(session[:id])
          @registers=Register.all
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

    if params[:print]
          render :print
    end


    respond_to do |format|
        format.html 
        format.json { 
           json_string = render_to_string   
           json_object = JSON.parse(json_string) 
           stream = JSON.pretty_generate(json_object)     
           send_data(stream, :type=>"text/json",:filename => @id+"_patient.json")
           # as canonical json
           # stream = render_to_string
        }

    end
    

 
	end

  

  def get_json_stream(id,action)
              filename = @id+"_"+action+".json"
              json_string= render_to_string(:action => action, :layout => false)
              json_object = JSON.parse(json_string) 
              stream = JSON.pretty_generate(json_object)
              return [filename,stream]
  end

  def fhirlist
    @orions=RegisterPatient.where(register_id: 1)
    content=""
    @orions.each do |orion|
        content=content+orion.patient_id.to_s+":"
    end
    path = "/Users/tlembke/Documents/AladdinDocs/path.txt"
    File.open(path, "w+") do |f|
        f.write(content)
    end

    @count=@orions.count
  end

    def fhir
      # this is for json
        @id=params[:id]
        connect_array=connect()
        @error_code=connect_array[1]
        if (@error_code==0)
          dbh=connect_array[0]
          @patient=get_patient(@id,dbh)
          @hpio = get_hpio(dbh)

          #  @meds=tasks_array[1]
          # @notes=tasks_array[2]
          #  @plan = tasks_array[3]
          # tests_array= get_tests(@plan)
          # @tests= tests_array[0]
          # @plan= tests_array[1]
          @medications = get_medications_amt(@id,dbh)
          # @appointments = get_appointments(@id,dbh)
          # @measures = get_measures(@id,dbh)
          @current_problems = get_current_problems(@id,dbh)
          # Problem,Note,Confidential,TermCode,ICPCCode,Id,DiagnosisDate
          #history_array = get_history(@id,dbh)
          #@procedures=history_array[0]
          #@events=history_array[1]
          @allergies=get_allergies(@id,dbh)
          # @careteam=get_careteam(@id,dbh)
          #@phonetime = get_phonetime(session[:id])
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

        

           #json_string = render_to_string   
           #json_string_2 = render_to_string
           #json_object = JSON.parse(json_string) 
           #stream = JSON.pretty_generate(json_object) 

           #send_data(stream, :type=>"text/json",:filename => @id+"_medications.json")
           # as canonical json
           # stream = render_to_string
           
          compressed_filestream = Zip::OutputStream.write_buffer do |zos|
              json_file=get_json_stream(@id,"medications")
              zos.put_next_entry json_file[0]
              zos.print json_file[1]

              json_file=get_json_stream(@id,"allergies")
              zos.put_next_entry json_file[0]
              zos.print json_file[1]

              json_file=get_json_stream(@id,"conditions")
              zos.put_next_entry json_file[0]
              zos.print json_file[1]


              json_file=get_json_stream(@id,"patient")
              zos.put_next_entry json_file[0]
              zos.print json_file[1]
          end

          compressed_filestream.rewind
          send_data compressed_filestream.read, filename: @id+".zip", type: 'application/zip'
        
    

  end


  def annual

    @id=params[:id]
    connect_array=connect()
    @error_code=connect_array[1]
    if (@error_code==0)
          dbh=connect_array[0]
          @patient=get_patient(@id,dbh)


          # Deafult Get last consult details
          # Unless otherwise selected

          sql = "SELECT ConsultDate, DoctorName,Plan,Diagnosis,History, Examination, Id FROM Consult WHERE PT_Id_FK = " + @id + " ORDER BY ConsultDate DESC LIMIT 1"
          
          puts sql
          sth = dbh.run(sql)
           sth.fetch_hash do |row|
            row['CONSULTDATE']=row['CONSULTDATE'].to_date
            @consult = row
          end
          sth.drop

          @prescription_history= Patient.prescription_history(@patient.id,dbh,Date.today.strftime("%Y-%m-%d"))

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
          @diabetes=has_condition?("diabetes",@current_problems)
          @ihd=has_condition?("ihd",@current_problems)
          unless @ihd
              @ihd=has_condition?("ihd",@procedures)
          end
          unless @ihd
              @ihd=has_condition?("ihd",@events)
          end
          @ckd = has_condition?("ckd",@current_problems)

          @allergies=get_allergies(@id,dbh)
          @careteam=get_careteam(@id,dbh)
          @phonetime = get_phonetime(session[:id])
          @all_measures=get_all_measurements(@id,dbh,50)

          measure_list=["Blood Pressure","Weight","Lipids"]
          @measures=[]
          measure_list.each do |next_measure|
            @this_measure = Measure.find_by Name: next_measure
            @measures << @this_measure
          end

          @ecg =  get_last_ecg(@patient.id,dbh)

          @immunisations=get_immunisations(@id,dbh)

          # Tetanus true if never given or if last booster more than 15 years ago unless given over age 65
          @tetanus = get_tetanus(@immunisations)
          @tetanus_msg = false
          if @tetanus
            last_given_age = @patient.age.to_i - @tetanus.year
          else
            last_given_age = 0
            @tetanus_msg = true unless @patient.age < 30
          end
          if @tetanus and @tetanus < 15.years.ago and last_given_age <65 and @patient.age > 30
                   @tetanus_msg = true
          end
             
          # need to get latest BP, Chol and HDL
          bpsweights=get_bps(@id,dbh,50)
          @bps=bpsweights[0]
          @weights=bpsweights[1]
          @heights=bpsweights[2]
          @bp=0
          if @bps.count > 0
            @bp=@bps[0]["SYSTOLIC"]
            @bpd=@bps[0]["DIASTOLIC"]
            @bp_date=@bps[0]["MEASUREMENTDATE"]
          end
          @weight=0
          if @weights.count>0
            @weight=@weights[0]["WEIGHT"]
            @weight_date=@weights[0]["MEASUREMENTDATE"]
          end
          @height=0
          if @heights.count > 0 
            @height=@heights[0]["HEIGHT"]
            @height_date=@heights[0]["MEASUREMENTDATE"]
          end


            @bmi=get_bmi(@height,@weight)


          @lipids=get_lipids(@id,dbh,20)
          @chol=0
          @hdl=0
          if @lipids.count > 0 
            @chol=@lipids[0]["CHOLESTEROL"]
            @chol_date=@lipids[0]["MEASUREMENTDATE"]
            flag=0
            @lipids.each do |lipid|
              if flag==0
                    if lipid["HDL"]
                      @hdl=lipid["HDL"]
                      @hdl_date=lipid["MEASUREMENTDATE"]
                      flag=1
                    end
               end
            end
          end
          
          @smoking = @patient.smoking
          @smoking ==1 ? smokingflag=1 : smokingflag = 0
          @alcohol = @patient.etoh
          @alcoholinfo = @patient.etohinfo
          if @patient.sex == "F"
            @mammogram = @patient.mammogram
            @last_scanned_mammogram = get_last_mammogram_scans(@id,dbh)
          end
          results_check=get_last_mammogram_fhh_results(@id,dbh,@patient.sex)
          @last_results_mammogram=results_check[0]
          @last_fhh=results_check[1]

          if @patient.sex =="F"

                #first which is most recent s can or results or both 0
                @mammogram= 0 if @mammogram == nil
                @last_mam = @mammogram


                @last_mam = @last_scanned_mammogram if @last_mam != 0 and @last_scanned_mammogram !=0  and @last_scanned_mammogram > @last_mam
               
                @last_mam = @last_results_mammogram if @last_mam == 0 or  (@last_results_mammogram > @last_mam)

                @mam = {:color => "green", :msg => "Not required" }
                if @patient.age >49 and @patient.age <71
                    @mam = {:color => "red", :msg => "Mammogram recommended" } if @last_mam ==0 or @last_mam < 2.years.ago
                    @mam = {:color => "green", :msg => "Mammogram Up To Date" } if @last_mam !=0 and @last_mam >  1.years.ago
                    @mam = {:color => "orange", :msg => "Mammogram Due next 12 months" } if @last_mam !=0 and @last_mam < 1.years.ago and @last_mam > 2.years.ago


                end
                
                 if @patient.age < 20 or @patient.age > 70 or @patient.pap_recall 
                        @pap = {:color => "green", :msg => "No PAP recall" }
                 else

                      @pap = {:color => "green", :msg => "PAP up to date" } if @patient.pap and @patient.pap >  2.years.ago
                      @pap = {:color => "red", :msg => "PAP due" } if @patient.pap ==nil or @patient.pap <  2.years.ago
                end
         end
         

          @colonoscopy = last_colonoscopy(history_array)
         

            if @diabetes and @patient.age > 60
                @score = { :value => 100, :color => "orange", :cat => "aged over 60 and presence of diabetes" }
            elsif @ckd
                 @score = { :value => 100, :color => "orange", :cat => "presence of Chronic Kidney Disease" }
            elsif @ihd
                 @score = { :value => 200, :color => "orange", :cat => "Ischaemic Heart Disease already documented" }
            elsif @patient.atsi==1 and @patient.age > 75
                 @score = { :value => 100, :color => "orange", :cat => "aged over 75 and ATSI" }
            elsif @chol.to_f > 7.5
                 @score = { :value => 100, :color => "orange", :cat => "Cholesterol over 7.5"}
            elsif @bp > 180
                 @score = { :value => 100, :color => "orange", :cat => "Blood pressure > 180" }
            else  
                 if @chol.to_f > 0  and @hdl.to_f  > 0 and @bp.to_i > 0 
                        @score=get_cardiac_risk(@patient.age,@patient.sex,@chol, @hdl,@bp, smokingflag)
                 else
                      msg="Unable to calculate Absolute cardiac risk as missing"
                      msg= msg+ " Cholesterol" unless @chol.to_i > 0 
                      msg= msg+ " HDL" unless @hdl.to_i > 0 
                      msg= msg+ " BP" unless @bp.to_i > 0
                      @score = { :value => 200, :color => "orange", :cat => msg }
                 end 


            end

          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

  

    respond_to do |format|
        format.html{
            if params[:precheck]
                  render :precheck
                  return
            end
        }


        format.json { 
           json_string = render_to_string   
           json_object = JSON.parse(json_string) 
           stream = JSON.pretty_generate(json_object)     
           send_data(stream, :type=>"text/json",:filename => @id+"_patient.json")
           # as canonical json
           # stream = render_to_string
        }
    end
    

 
  end

  def get_bmi(height,weight)
      if height ==0 or weight == 0 
        bmi = { :value => 0}
      else
        height = height/100 # convert from cm to m
        value = weight / (height * height)
        upper = (25 * height * height).round(0)
        lower = (20 * height * height).round(0)
        range = lower.to_s + " - " + upper.to_s
        color="green"
        color="orange" if value > 25
        color="red" if value > 30
        bmi = { :value => value.round(0), :range => range, :upper => upper, :lower => lower, :color => color}
      end
      return bmi





  end

  def get_cardiac_risk(age,sex,chol,hdl,bp,smoking=0, htmed=0)
         total_score=0

          # Age
          sex=="M" ? s=1 : s=0
          k = 0.057*age - 8.65 + 0.008*bp + 0.18*chol.to_f + 0.234*hdl.to_f + 0.61*s + 0.458*smoking + 0.749*htmed
          k = - k 
          risk = 1 / ( 1 + Math.exp(k) )
    
          risk = risk * 100
          if risk < 10
                  color="green"
                  cat="Low"
          elsif risk <15
                  color="orange"
                  cat = "Moderate"
          else
                  color="red"
                  cat = "High"
          end
          score = { :value => risk, :color => color, :cat => cat }
          return score

  end

  def get_tetanus(immunisations)
    givenDate = false
    immunisations.each do |imm|
      if givenDate == false
        if imm["VACCINE"].downcase == "adt" or imm["VACCINE"].downcase == "boostrix"
          givenDate = imm["GIVENDATE"]
        end
      end
    end
    return givenDate

  end

  def get_cardiac_risk2(age,sex,chol,hdl,bp)
       total_score=0
          # Age

          if sex=="F"
            value_array=[[34,-9],[39,-4],[44,0],[49,3],[54,6],[59,7],[64,8],[69,8],[74,8],[79,8]]
          else
              value_array=[[34,-1],[39,0],[44,1],[49,2],[54,3],[59,4],[64,5],[69,6],[74,7]]
          end

          total_score = total_score + get_score(value_array,age)
          puts " Age Score " + total_score.to_s

          # Total Cholesterol
          if sex =="F"           
              value_array=[[4.14,-2],[5.17,0],[6.21,1],[7.24,1],[100,3]]        
          else
            value_array=[[4.14,-3],[5.17,0],[6.21,1],[7.24,2],[100,3]] 
          end
          old_score=total_score
          total_score = total_score + get_score(value_array,chol)
          puts "Chol Score " + (total_score - old_score).to_s

          # HDL Cholesterol
          if sex =="F"           
              value_array=[[0.9,5],[1.16,2],[1.29,1],[1.55,0],[5,-3]]       
          else
            value_array=[[0.9,2],[1.16,1],[1.29,0],[1.55,0],[5,-2]]
          end
          old_score=total_score
          total_score = total_score + get_score(value_array,hdl)
          puts "HDL Score " + (total_score - old_score).to_s


          # Blood Pressure
          if sex =="F"           
              value_array=[[120,-3],[129,0],[139,0],[159,2],[300,3]]      
          else
                value_array=[[120,0],[129,0],[139,1],[159,2],[300,3]]
          end
          old_score=total_score
          total_score = total_score + get_score(value_array,bp)
          puts "BP Score" + (total_score - old_score).to_s
          puts "Total Score is " + total_score.to_s

          # Smoker
          # +2

          # Diabetes
          # +2 = High Risk

          # Risk %
          if sex =="F"           
            value_array=[[0,2],[1,2],[2,3],[3,3],[4,4],[5,4],[6,5],[7,6],[8,7],[9,8],[10,10],[11,11],[12,13],[13,15],[14,18],[15,20],[16,24],[100,27]]          
          else
            value_array=[[0,3],[1,3],[2,4],[3,5],[4,7],[5,8],[6,10],[7,13],[8,16],[9,20],[10,25],[11,31],[12,37],[13,45],[20,53]]          
          end
          risk=get_score(value_array,total_score)



          return risk
  end


  def get_score(value_array,value)
      score=0
      flag=true
      value_array.each do |pair|
        if value<=pair[0] and flag             
            score = pair[1]
            flag=false
        end
      end
      return score

  end

  def points_assign(value,upper,score)
    puts upper,score
    use=false
    if value < upper
      use=true
    end
    return [use,score]
  end


  def billing
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
          #@provider = session[:provider]
          #@username = session[:username]
          # @medications = get_medications(@id,dbh)
          #@appointments = get_appointments(@id,dbh)
          # @measures = get_measures(@id,dbh)
          #@current_problems = get_current_problems(@id,dbh)
          #history_array = get_history(@id,dbh)
          #@procedures=history_array[0]
          #@events=history_array[1]
          #@allergies=get_allergies(@id,dbh)
          #@careteam=get_careteam(@id,dbh)
          #@ahp_items=get_ahp_items
          #bpsweights=get_bps(@id,dbh,50)
          #@bps=bpsweights[0]
          #@weights=bpsweights[1]
          #@lipids=get_lipids(@id,dbh,50)
          #@all_measures=get_all_measurements(@id,dbh,50)
          #@tracked_items=[721,723,732,2517,2521,701,703,900]
          #@item_numbers=get_item_numbers(@id,dbh,@tracked_items)
          #@phonetime = get_phonetime(session[:id])
          #@lastSHS = get_shs_date(@id,dbh)
          @invoices=get_invoices(@id,dbh)
          
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
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
          @provider = session[:provider]
          @username = session[:username]
          @medications = get_medications(@id,dbh)
          @appointments = get_appointments(@id,dbh)
          # @measures = get_measures(@id,dbh)
          @current_problems = get_current_problems(@id,dbh)
          history_array = get_history(@id,dbh)
          @procedures=history_array[0]
          @events=history_array[1]
          @allergies=get_allergies(@id,dbh)
          @careteam=get_careteam(@id,dbh)
          @ahp_items=get_ahp_items
          bpsweights=get_bps(@id,dbh,50)
          @bps=bpsweights[0]
          @weights=bpsweights[1]
          @lipids=get_lipids(@id,dbh,50)
          @all_measures=get_all_measurements(@id,dbh,50)
          @tracked_items=[721,723,732,2517,2521,701,703,900]
          @item_numbers=get_item_numbers(@id,dbh,@tracked_items)
          @phonetime = get_phonetime(session[:id])
          @lastSHS = get_shs_date(@id,dbh)
          @users = get_users(dbh)
          @provider = session[:provider]
          @epc_count = get_epc_count(@id)

          
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end



    respond_to do |format|
        format.html {
            if params[:print]
                  @print = true
                  render :careplanprint
                  return
            end


        }
        format.pdf {
                  render pdf: 'care_plan',
                  layout: 'layouts/pdf.html.erb',
                  template: "patient/careplanprint.html.erb",
                  show_as_html: params.key?('debug')
        }
    end



  end


def healthsummary
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
          
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end

    if params[:print]
          @print = true
          render :healthsummaryprint
    end


  end




  def epc

    @name = session[:name]
    @username = session[:username]
    @provider = params[:provider]
    @id=params[:id]
    @member = params[:member]
    @craft = params[:craft]
    @no_visits = params[:noVisits]
    connect_array=connect()
    @error_code=connect_array[1]
    @ahp_items=get_ahp_items
    if (@error_code==0)
          dbh=connect_array[0]
        # Get info about this patient
          @patient=get_patient(@id,dbh)

          @ahp=get_ahp(@member,dbh)
          @name = get_provider(dbh,@provider)
          
          dbh.disconnect


    else
          # lost connection to database
          flash[:notice]=connect_array[2]
          redirect_to  action: "login"
    end



  end

  def get_hpio(dbh)
          sql = "SELECT HPIO FROM PracticePreference WHERE Id= 1"
          puts sql
         

          sth = dbh.run(sql)
               
          hpio=""
          sth.fetch_hash do |row|
              hpio = row['HPIO']
          end
          sth.drop
          return hpio

  end


  def get_ahp(member_id,dbh)
          sql = "SELECT FullName, Category, Address1, Address2, Address3, Address4, Specialty, WorkPhone, Suburb FROM AddressBook WHERE Id= " + member_id.to_s
          puts sql
         

          sth = dbh.run(sql)
               
          ahp=sth.fetch_hash

          sth.drop
          return ahp

    end

      def get_invoices(patient,dbh)
          sql = "SELECT Sum(Fee) as SumTotal, Sum(Rebate) as RebateTotal FROM Sale WHERE PT_Id_FK = " + patient.to_s + " AND ServiceDate > '" + 1.years.ago.to_s(:db) + "'"
          puts sql
         

          sth = dbh.run(sql)
               
          invoices=sth.fetch_hash

          sth.drop

          return invoices

    end
  def get_ahp_items
        ahp_items={ "Dietitian" => 10954, "Physiotherapist" => 10960, "Physio" => 10960, "Audiologist" => 10952, "Aboriginal Health Worker" => 10950, "Chiropractor" => 10964, "Chiropractic" => 10964,"Diabetes Educator" => 10951, "Diabetic Educator" => 10951,"Exercise Physiologist" => 10953, "Mental Health Worker" => 10956, "Occupational Therapist" => 10958, "Osteopath" => 10966, "Podiatrist" => 10962, "Psychologist" => 10968, "Speech Pathologist" => 10970}
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
      @cond_select.unshift ["General","0"]
      @cond_select.unshift ["Import to...",""]
      

      dbh.disconnect
  end

   def register

      id=params[:id]
      register_id=params[:register]
      @register = RegisterPatient.where("patient_id= ? and register_id = ?",id,register_id)
      if @register.count > 0
            @register.each do |reg |
              reg.destroy
            end
      else
            @new_register=RegisterPatient.new(patient_id: id, register_id: register_id)
            #@new_register.update_attribute(:register_id, register_id)
            #@new_register.update_attribute(:patient_id, id)
            @new_register.save
      end
      render :nothing => true 
 end

  private

  def get_users(dbh)
          sql = "SELECT  Name, ProviderNum FROM Preference  where Inactive = False and ProviderType = 2 and ProviderNum <> '' ORDER BY Surname"
          puts sql
         

          sth = dbh.run(sql)
               
          users=[]
          sth.fetch_hash do |row|
            users << [row['NAME'],row['PROVIDERNUM']]
          end

          sth.drop
          return users



  end

  def get_provider(dbh,providerNum)
          sql = "SELECT Name FROM Preference where ProviderNum  = '%s'" % providerNum
          puts sql

          sth = dbh.run(sql)
          @error = ODBC.error

         
          sth.fetch do |row|

              @name=row[0]


          end
          sth.drop
          return @name
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

    def get_immunisations(patient,dbh)
          sql = "SELECT ACIRCode, GivenDate, Vaccine FROM Vaccination WHERE PT_Id_FK = " + patient.to_s + "ORDER BY GivenDate DESC"
          puts sql
         

          sth = dbh.run(sql)
               
          immunisations=[]
          sth.fetch_hash do |row|

            immunisations<< row
          end

         

         
          sth.drop
          return immunisations

    end


    def get_medications_amt(patient,dbh)
          sql = "SELECT Medication, Dose, Frequency, Instructions, Category, CreationDate, DrugIndexCode, Id FROM Prescription WHERE Prescription.PT_Id_FK = " + patient.to_s
          puts sql

         

          sth = dbh.run(sql)
          
          medications=[]
          sth.fetch_hash do |row|
            
             # now we need to find AMT code
            puts row["DRUGINDEXCODE"]
            code=row["DRUGINDEXCODE"].split('/')
            code[0]=code[0].gsub(/^\D/,'')
            sql2= "SELECT LinkAMT.AMTCode, AMTName from LinkAMT,AMTDescription where prodcode = " + code[0] + " and formcode = " + code[1] + " and packcode = " + code[2] + "and AMTDescription.AMTCode = LinkAMT.AMTCode "
            puts sql2
            sth2 = dbh.run(sql2)
            sth2.fetch do |row2|
              row["AMT"]= row2[0]
              row["AMTName"] = row2[1]
            end
            sth2.drop

            #row["INSTRUCTIONS"]=expand_instruction(row["INSTRUCTIONS"])
            #row["FREQUENCY"]=expand_instruction(row["FREQUENCY"])
            # now we need to find AMT code
        
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

         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, Scratchpad, FamilyHistory, MedicareNum, MedicareRefNum, IHI, HomePhone, MobilePhone, SmokingFreq, Alcohol, AlcoholInfo, LastMammogram, CultureCode, EmailAddress, LastSmear, NoPapRecall FROM Patient WHERE id = "+patient       
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            atsi=0
            row['CULTURECODE'] > 3 ? atsi=0 : atsi=1

            @patient=Patient.new(id: @id, surname: row['SURNAME'], firstname: row['FIRSTNAME'], fullname: row['FULLNAME'], lastseendate: row['LASTSEENDATE'], lastseenby: row['LASTSEENBY'], addressline1: row['ADDRESSLINE1'], addressline2: row['ADDRESSLINE2'],suburb: row['SUBURB'],dob: row['DOB'], age: row['AGE'], sex: row['SEX'], scratchpad: row['SCRATCHPAD'], social: row['FAMILYHISTORY'], ihi: row['IHI'],medicare: row['MEDICARENUM'].to_s + "/" + row['MEDICAREREFNUM'].to_s,homephone: row['HOMEPHONE'],mobilephone: row['MOBILEPHONE'], smoking: row['SMOKINGFREQ'], etoh: row['ALCOHOL'], etohinfo: row['ALCOHOLINFO'], mammogram: row['LASTMAMMOGRAM'], atsi: atsi, email: row['EMAILADDRESS'], pap: row['LASTSMEAR'],pap_recall: row['NOPAPREACLL'])
          end
          sth.drop
          return @patient
  end

 def has_condition?(condition,problems)
    icpc=""
    flag=false
    if condition =="ihd"
        icpc = %w(k74 K75 K76 K54007 K53003 K53009)
    end
    if condition =="diabetes"  
        icpc = %w(T89 T90)
    end
    if condition =="ckd"  
        icpc = %w(U99)
    end
    if icpc!=""
      problems.each do |problem |
        if flag==false
            icpc.each do |code|
              if problem["ICPCCODE"].start_with?(code)
                flag=true
              end
            end
        end
      end
    end

    
    return flag
end 

 def last_colonoscopy(history)
    colon=false
    colon_date=Date.new(1980,1,1)
    history.each do | problemlist |
        problemlist.each do | problem |
          if problem["HISTORY"].downcase.include?("colonoscopy")
                if problem["CREATIONDATE"] > colon_date
                  colon=problem["HISTORY"]
                  colon_date=problem["CREATIONDATE"]
                end
             
          end
        end
      end

  


    
    return [colon,colon_date]
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


          sql = "SELECT Systolic,Diastolic,Weight,Height,MeasurementDate FROM Measurement where PT_Id_FK = " + patient + " ORDER BY MeasurementDate Desc LIMIT "+ number.to_s
 
          puts sql
         

          sth = dbh.run(sql)
               


          # systolic BP is returned as string - drats
          bps=[]
          weights=[]
          heights=[]
          sth.fetch_hash do |row|
            row['SYSTOLIC']=row['SYSTOLIC'].to_i
            row['DIASTOLIC']=row['DIASTOLIC'].to_i
            
            if row['SYSTOLIC'] > 0
                bps << row
            end

            if row['WEIGHT'] > 0
                weights << row
            end
            if row['HEIGHT'] > 0
                heights << row
            end
          end
         

         
          sth.drop

          return [bps,weights,heights]


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

  def get_problem_list(patient,dbh)
  

  end


  def get_current_problems(patient,dbh)

        sql = "SELECT Problem,Note,Confidential,TermCode,ICPCCode,Id,DiagnosisDate,SnomedCode FROM CurrentProblem where PT_Id_FK = " + patient
 
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

    def get_images(patient,dbh)

        sql = "SELECT Description, ImageDate FROM  Graphic where PT_Id_FK = " + patient
 
          puts sql
         

          sth = dbh.run(sql)
               
          images=[]
          sth.fetch_hash do |row|
            images<< row
          end

         

         
          sth.drop
          return images

  end 

  def get_last_ecg(patient,dbh)

        sql = "SELECT Description, ImageDate FROM  Graphic where PT_Id_FK = " + patient + " AND Description LIKE '%ecg%'  ORDER BY ImageDate DESC"
 
          puts sql
         

          sth = dbh.run(sql)
               

          row= sth.fetch_first


         

         
          sth.drop
          row ? returnValue= row[1] : returnValue=0

          return returnValue

  end 

      def get_last_mammogram_scans(patient,dbh)

        sql = "SELECT Description, ImageDate FROM  Graphic where PT_Id_FK = " + patient + " AND (Description LIKE '%breast screen%' or Description LIKE '%breastscreen%') ORDER BY ImageDate DESC"
 
          puts sql
         

          sth = dbh.run(sql)
               

          row= sth.fetch_first


         

         
          sth.drop
          row ? returnValue= row[1] : returnValue=0

          return returnValue

  end 

        def get_last_mammogram_fhh_results(patient,dbh,sex)

        sql = "SELECT Test, CollectionDate FROM  DownloadedResult where PT_Id_FK = " + patient + " ORDER BY CollectionDate DESC"
 
          puts sql
         

          sth = dbh.run(sql)
               
          returnMAM=0
          returnFHH=0

          sth.fetch_hash do |row|
            if sex=="F"
              if row['TEST'].downcase.include? "xr breasts" and returnMAM==0
                  returnMAM = row['COLLECTIONDATE']
              end
            end
            if row['TEST'].downcase.include? "faecal blood" and returnFHH==0
                returnFHH = row['COLLECTIONDATE']
            end

          end
         

         
          sth.drop
          return [returnMAM, returnFHH]

  end 


  # ihd = k74,k75,k76,k54007,k53003,k53009
  # diabetes = t89,t90


  def get_allergies(patient,dbh)

        sql = "SELECT Allergy,Detail,ClassCode,GenericCode FROM Allergy where PT_Id_FK = " + patient
 
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
          sql = "SELECT History,Note, Procedure,TermCode,ICPCCode,Confidential,CreationDate FROM PastHistory where Confidential = false AND PT_Id_FK = " + patient 
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
          theDate = Time.now
          theYear=theDate.strftime("%Y")
          sql = "SELECT ProviderName, ProviderPhone,ProviderType, Specialty, Category, AB_Id_Fk as address_book_id FROM InterestedParty, AddressBook where InterestedParty.PT_Id_FK = " + patient + " AND AddressBook.Id = InterestedParty.AB_Id_Fk"
          puts sql
          sth = dbh.run(sql)
          careteam=[]
          sth.fetch_hash do |row|
              member = Member.find_or_create_by(patient_id: patient, genie_id: row['address_book_id'])
              if member.year_reset == nil or member.year_reset < theYear.to_i
                  member.update(year_reset: theYear, epc: 0)
              end
              row['member']=member
              if row['PROVIDERTYPE']==""
                row['PROVIDERTYPE']=row['CATEGORY']
              end
              if row['PROVIDERTYPE']==""
                row['PROVIDERTYPE']=row['SPECIALTY']
              end
              
              careteam << row
          end
          sth.drop

          # reset epc count if new year has passed

          # members = Member.where("year_reset = '' or year_reset < ?", @year).update_all(year_reset: @year, epc: 0)
          return  careteam
  end



  def get_shs_date(patient,dbh)
      sql = "SELECT CreationDate FROM CDA where PT_Id_FK = " + patient + " AND SentToPCEHR = true ORDER BY CreationDate DESC"
          puts sql
          sth = dbh.run(sql)
          lastSHS = nil
          sth.fetch_hash do |row|
            lastSHS = row['CREATIONDATE']
          end
          sth.drop
          return lastSHS
  end

  def get_epc_count(patient)
          epc_count=Member.where(patient_id: patient).sum(:epc)
          return epc_count

  end


  def get_phonetime(doctor)
    @phonetime=Phonetime.find_by_doctor_id(doctor)
    if @phonetime
     return @phonetime.message
    else
      return nil
    end
 end

   def patient_params
      params.permit(:id,:register)
  end


end
