class Patient
  include ActiveModel::Model

  attr_accessor :id, :surname, :firstname, :age, :sex, :fullname, :lastseendate, :lastseenby, :addressline1, :addressline2, :suburb, :dob, :scratchpad, :social, :medicare, :ihi, :homephone, :mobilephone, :smoking, :etoh,  :etohinfo, :nutrition, :activity, :mammogram, :atsi, :email, :pap, :pap_recall, :medications, :allergies, :weight, :height, :weight_date, :height_date, :bmi, :bp, :colonoscopy, :lastFHH, :last_mam, :mam_msg, :pap_msg, :chol, :hdl, :score, :tetanus, :tetanus_msg, :procedures, :events, :current_problems, :tasks, :meds, :notes, :plan, :appointments, :changes, :tests, :careteam,  :ecg, :bps, :lipids, :lastFHHnew

  

  
  def self.get_patient(patient,dbh)
          # ? deprecated
            # Get info about this patient
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, Scratchpad, FamilyHistory FROM Patient WHERE id = "+patient       
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            @patient=Patient.new(id: @id, surname: row['SURNAME'], firstname: row['FIRSTNAME'], fullname: row['FULLNAME'], lastseendate: row['LASTSEENDATE'], lastseenby: row['LASTSEENBY'], addressline1: row['ADDRESSLINE1'], addressline2: row['ADDRESSLINE2'],suburb: row['SUBURB'],dob: row['DOB'], age: row['AGE'], sex: row['SEX'], scratchpad: row['SCRATCHPAD'], social: row['FAMILYHISTORY'], smoking: row['SMOKINGFREQ'],etoh: row['ALCOHOL'], etohinfo: row['ALCOHOLINFO'], mammogram: row['LASTMAMMOGRAM'] )
          end
          sth.drop
          return @patient
  end

  def self.medications(patient,dbh)
          sql = "SELECT Medication, Dose, Frequency, Instructions, Category, CreationDate FROM Prescription WHERE PT_Id_FK = " + patient + " ORDER BY Medication"
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

  def self.prescription_history(patient,dbh,date)
          sql = "SELECT * FROM PrescriptionHistory WHERE PT_Id_FK = " + patient + "and  DateOfChange = '" + date + "'"
          puts sql
         

          sth = dbh.run(sql)
               
          prescription_history=[]
          sth.fetch_hash do |row|
            # Drug Name - Tablets is repeated in Dose
            drug=row['DrugName'].sub(" Tablets","")
            drug=drug.sub(" Capsules","")
            row['Dose']=row['Dose'].sub(drug,"")
            prescription_history << row
          end

          sth.drop



          return prescription_history

    
  end

  def self.billing(patient,dbh,date)
          sql = "SELECT * FROM PrescriptionHistory WHERE PT_Id_FK = " + patient + "and  DateOfChange = '" + date + "'"
          puts sql
         

          sth = dbh.run(sql)
               
          prescription_history=[]
          sth.fetch_hash do |row|
            # Drug Name - Tablets is repeated in Dose
            drug=row['DrugName'].sub(" Tablets","")
            drug=drug.sub(" Capsules","")
            row['Dose']=row['Dose'].sub(drug,"")
            prescription_history << row
          end

          sth.drop



          return prescription_history

    
  end

  def general_goals
  		general_goals = Goal.where(patient_id: self.id, condition_id: 0)
  		return general_goals
  end

  def overall_goals
      general_goals = Goal.where(patient_id: self.id, condition_id: 0)
      return general_goals
  end

    def has_plan?
        @goals=Goal.where(patient_id: self.id)
        @goals.count > 0 ? returnText = true : returnText = false
        return returnText
  end


  def pronoun
  	    self.sex=="F"  ?  pronoun = "She" : pronoun = "He"

 end

   def pospronoun
  	    self.sex=="F"  ?  pospronoun = "Her" : pospronoun = "His"

  end

  def introduction
  	    # plan has \r instead of \m
    social=self.social.split("\r")
    social=social.join("\n")

    if self.sex=="F" 
    	pronoun = "She"
    	title="woman"
    else
    	pronoun = "He"
    	title = "man"
    end
    identifier=title
    # is there identifier in scratchpad?

    match1=social.match /^-(\s?i\s+)(.*)/
    if match1
          # ok, we have a match for -i 
		  identifier=match1[2]
      social=social.sub match1[0],''
      social=social.strip
    end
    lives=""

    while (match2=social.match /^-(\s?l(ives)?\s+)(.*)/) do 
      if match2
            # ok, we have a match for -l or -lives
  		lives+=match2[3]+"<p>"
      end
      social=social.sub match2[0],'' 
      social=social.strip
    end
    care=""
    while (match3=social.match /^-(\s?c(are)?r?\s+)(.*)/) do
      if match3
          # ok, we have a match for -c or -care or -carer
		  care+=match3[3]+"<br>"
      end
      social=social.sub match3[0],''
      social=social.strip
    end
    narrative=""
    while (match4=social.match /^-(.*)/) do
      if match4
          # ok, we have a match for -c or -care or -carer
      narrative+=match4[1]+"<br>"
      end
      social=social.sub match4[0],''
      social=social.strip
    end
    

      # end
    




    introduction=self.fullname + " is a " + self.age.to_s+ " year old " + identifier + ".<br>"
   
    if lives != ""
    
        lives= lives.sub(/^lives/, '')
    		lives=lives.strip
    		introduction+= pronoun + " lives " + lives +".<br>"
    end

    if care != ""
    		introduction+= pronoun + " is " + care +".<br>"
    end

    introduction+= narrative


    
    return introduction

  end

    def self.expand_instruction(instruction)
    e = HashWithIndifferentAccess.new #=> {}
    e['mane'] = "in the morning"
    e['nocte'] = "at night"
    e['tds'] = "three times a day"
    e['bd'] = "twice a day"
    e['prn'] = "as required"
    keys=e.keys
    keys.each do |short|
      instruction=instruction.sub short, e[short]
    end
    return instruction
  end

  def self.has_goal?(id,goal)
        @parent=Goal.where("patient_id= ? and parent = ?",id,goal)
        @parent.count > 0 ? returnText = true : returnText = false
        return returnText
  end

  def autoload_goals
        # this is to load automatic goals for patient
        # egneral goals have condition_id 0
        # master goals have patient_id = 0 and belong to parent parent
        # parent will be 0 for general



        cats= Goal.autoloads

        cats.each do |category|
            condition_id=self.has_condition(category)
            
            if condition_id
                autoload_goals=Goal.where(patient_id: 0, autoload: category)
                
                autoload_goals.each do |master|
                  newgoal = master.dup
                  newgoal.patient_id = self.id
                  newgoal.condition_id = condition_id
                  newgoal.save!
                end
            end
        end


  end

  def has_condition(condition)
    icpc=""
    flag=false
    if condition =="general"
        flag=0
    else

        if condition =="ihd"
            icpc = %w(k74 K75 K76 K54007 K53003 K53009)
        end
        if condition =="diabetes"  
            icpc = %w(T89 T90)
        end
        if condition =="ckd"  
            icpc = %w(U99)
        end
        if condition =="prostateca"  
            icpc = %w(Y77)
        end
        if icpc!=""
          self.current_problems.each do |problem |
            unless flag
                icpc.each do |code|
                  if problem["ICPCCODE"].start_with?(code)
                    flag=problem["ID"]
                  end
                end
            end
          end
        end

    end

    
    return flag
end 



  def register(register_id)
      @register = RegisterPatient.where("patient_id= ? and register_id = ?",self.id,register_id)
      @register.count > 0 ? returnText = true : returnText = false
      return returnText
  end




end
