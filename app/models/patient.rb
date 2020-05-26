class Patient
  include ActiveModel::Model



  

  attr_accessor :id, :surname, :firstname, :age, :sex, :fullname, :lastseendate, :lastseenby, :addressline1, :addressline2, :suburb, :dob, :scratchpad, :social, :medicare, :ihi, :homephone, :mobilephone, :smoking, :etoh,  :etohinfo, :nutrition, :activity, :mammogram, :atsi, :email, :pap, :hpv, :hpv_recall, :medications, :allergies, :weight, :height, :weight_date, :height_date, :bmi, :bp, :colonoscopy, :lastFHH, :last_mam, :mam_msg, :hpv_msg, :chol, :hdl, :score, :tetanus, :tetanus_msg, :procedures, :events, :current_problems, :tasks, :meds, :notes, :plan, :appointments, :changes, :tests, :careteam,  :ecg, :bps, :lipids, :lastFHHnew, :results, :unlinkedresults

  

  
  def self.get_patient(patient,dbh)
          # ? deprecated
            # Get info about this patient
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,AddressLine1, AddressLine2,Suburb,DOB, Age, Sex, Scratchpad, FamilyHistory, HomePhone, MobilePhone FROM Patient WHERE id = "+patient       
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            @patient=Patient.new(id: patient, surname: row['SURNAME'], firstname: row['FIRSTNAME'], fullname: row['FULLNAME'], lastseendate: row['LASTSEENDATE'], lastseenby: row['LASTSEENBY'], addressline1: row['ADDRESSLINE1'], addressline2: row['ADDRESSLINE2'],suburb: row['SUBURB'],homephone: row['HOMEPHONE'],mobilephone: row['MOBILEPHONE'],dob: row['DOB'], age: row['AGE'], sex: row['SEX'], scratchpad: row['SCRATCHPAD'], social: row['FAMILYHISTORY'], smoking: row['SMOKINGFREQ'],etoh: row['ALCOHOL'], etohinfo: row['ALCOHOLINFO'], mammogram: row['LASTMAMMOGRAM'] )
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

    def self.letters(patient,dbh)

          sql = "SELECT Id, Sender, LetterDate, LetterContent_, LetterContentText, LetterType FROM IncomingLetter WHERE PT_Id_FK = " + patient + " ORDER BY LetterDate DESC LIMIT 20"
          puts sql 



          
         

          sth = dbh.run(sql)
          
          letters=[]
          sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            letters << row

              end
          

          sth.drop

     
  
          return letters
  end
    def self.unlinkedletters(surname,dob,dbh)

          sql = "SELECT Id, Sender, LetterDate, LetterContent_, LetterContentText, LetterType FROM IncomingLetter WHERE PT_Id_FK = 0 and SURNAME = '" + surname + "' and DOB = '" + dob.strftime('%Y-%m-%d') +  "' ORDER BY LetterDate DESC LIMIT 20"
          puts sql 



          
         

          sth = dbh.run(sql)
          
          letters=[]
          sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            letters << row

              end
          

          sth.drop

     
  
          return letters
  end


      def self.referrals(patient,dbh)

          sql = "SELECT Id, AddresseeName, LetterDate, ReferralContent_ FROM OutgoingLetter WHERE PT_Id_FK = " + patient + " ORDER BY LetterDate DESC LIMIT 20"
          puts sql 



          
         

          sth = dbh.run(sql)
          letters =[]
         
          sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            letters << row

              end
          

          sth.drop

     
  
          return letters
   end
     def self.scans(patient,dbh)

          sql = "SELECT Id, RealName, Description, ImageDate FROM Graphic WHERE PT_Id_FK = " + patient + " ORDER BY ImageDate DESC LIMIT 20"
          puts sql 



          
        

          sth = dbh.run(sql)
          
          scans=[]
          sth.fetch_hash do |row|

            # row[]=[row[2]].pack('H*')

            scans << row

              end
          

          sth.drop

     
  
          return scans
  end





    def self.allergies(patient,dbh)
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

  def recalls
      recalls = Member.where(patient_id: self.id, recallflag: true)
      total = Recall.cats.length
      i=0
      sortedRecalls=[]
      while i < total
        recalls.each do |member|
          if member.genie_id
            if member.recall.cat == i
              sortedRecalls << member
            end
          end
        end
        i=i+1
      end
      return sortedRecalls

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

  def paragraphs
       @paragraphs=Paragraph.where(patient_id: self.id)
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
      lives.sub(" his ", ' my ')
      lives.sub(" her ", ' my ')
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
    




    introduction="I am a " + self.age.to_s+ " year old " + identifier + ".<br>"
   
    if lives != ""
    
        lives= lives.sub(/^lives/, '')
    		lives=lives.strip
    		introduction+= "I live " + lives +".<br>"
    end

    if care != ""
    		introduction+= pronoun + " is " + care +".<br>"
    end

    introduction+= narrative


    
    return introduction

  end

   def cmaintroduction
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
      lives.sub(" his ", ' my ')
      lives.sub(" her ", ' my ')
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

  def is_in_nh?
    
   RegisterPatient.where(patient_id: self.id).joins(:register).where("Registers.code = 1").count >0 ? true : false

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

  def get_shs_date(dbh)
      sql = "SELECT CreationDate FROM CDA where PT_Id_FK = " + self.id + " AND SentToPCEHR = true ORDER BY CreationDate DESC"
          puts sql
          sth = dbh.run(sql)
          lastSHS = nil
          sth.fetch_hash do |row|
            lastSHS = row['CREATIONDATE'].to_date
          end
          sth.drop
          return lastSHS
  end

  def get_epc_count
          epc_count=Member.where(patient_id: self.id).sum(:epc)
          return epc_count

  end

   def self.get_patient_name_from_id(patient,dbh)
            # Get info about this patient
         sql = "SELECT Surname,FirstName FROM Patient WHERE id = " + patient.to_s   
         puts sql
          sth = dbh.run(sql)
          sth.fetch_hash do |row|
            @patient=Patient.new(id: patient, surname: row['SURNAME'], firstname: row['FIRSTNAME'])
          end
          sth.drop
          return @patient
  end

    def get_last_consult_for_reason(reason,dbh)
          sql = "SELECT ConsultDate FROM Consult, ConsultationProblem WHERE Consult.PT_Id_FK = " + self.id.to_s + " AND ConsultationProblem.CNSLT_Id_FK = Consult.ID AND ConsultationProblem.Problem ='"+ reason + "' ORDER BY Consult.ConsultDate DESC"
          puts sql
         

          sth = dbh.run(sql)
               
          row= sth.fetch_first
            
          row ? returnValue= row[0] : returnValue=false

          sth.drop
      
          return returnValue

  end

    def get_next_appointment(dbh)
          sql = "SELECT StartDate, StartTime, ProviderName,Reason FROM Appt WHERE PT_Id_FK = " + self.id.to_s + " AND StartDate > '" + Date.today.to_s(:db) + "' ORDER BY StartDate"
          puts sql
         

          sth = dbh.run(sql)
          appointment = sth.fetch_hash



          sth.drop



          return appointment
  end

     def get_item_number_date(dbh,item)
          


          sql = "SELECT  ServiceDate from Sale  where PT_Id_FK = " + self.id.to_s + " and (ItemNum = '"+item + "') ORDER BY ServiceDate DESC"
          puts sql
          sth = dbh.run(sql)
               
          row= sth.fetch_first
            
          row ? returnValue= row[0] : returnValue=false

          sth.drop
      
          return returnValue


  end

  def calevents
        events=[]
        # careteam available
        self.careteam.each do |ctmember|
            title= ctmember['PROVIDERNAME']
            title = title + ", " + ctmember['PROVIDERTYPE'] unless ctmember['PROVIDERTYPE'].blank?
            nextDay = ctmember['member']['nextDay']
            nextMonth = ctmember['member']['nextMonth']
            nextYear = ctmember['member']['nextYear']
            everyNumber = ctmember['member']['everyNumber']
            everyUnit = ctmember['member']['everyUnit']
            exactDate = ctmember['member']['exactDate']

            events = events +  getEvents(title, nextDay, nextMonth, nextYear, everyNumber, everyUnit, exactDate, 0)


          
        end

        # now we need to do the same for actions,
      

        members = Member.where(patient_id: self.id, recallFlag: true)
        members.each do |member|
              # genie_id should bever be nil
              unless member.genie_id == nil
                title = member.recall.title
                if title == "Custom"
                  title = member.note
                end
               
                events = events +   getEvents(title, member.nextDay, member.nextMonth, member.nextYear, member.everyNumber, member.everyUnit, member.exactDate, member.recall.cat)
              end
        end



        return events

  end

  def getEvents(title, nextDay, nextMonth, nextYear, everyNumber, everyUnit, exactDate, cat)
          newEvents =[]
          unless nextYear.blank? or nextYear == 0 
                #  nextDay = Date.today.day if nextDay == 0
                @event=Event.new(day: nextDay, month: nextMonth, year: nextYear, title: title, exactDate: exactDate, cat: cat)            
                newEvents << @event
          end

         unitUnknown = true
         if everyUnit and (everyUnit[0]=="d" or everyUnit[0]=="w" or everyUnit[0]=="m" or everyUnit[0]=="y")
              unitUnknown = false
         end


           
          unless everyNumber.blank? or everyUnit.blank? or unitUnknown
                # assumse starts from today unless specified
                nextDay = Date.today.day if nextDay == 0
                nextMonth= Date.today.month if nextMonth == 0
                nextYear= Date.today.year if nextYear == 0
                theDate=Date.new(nextYear, nextMonth, nextDay)
                while theDate < Date.today + 1.year
                  theDate = theDate + everyNumber.days if everyUnit.starts_with?("d")
                  theDate = theDate + everyNumber.weeks if everyUnit.starts_with?("w")
                  theDate = theDate + everyNumber.months if everyUnit.starts_with?("m")
                  theDate = theDate + everyNumber.years if everyUnit.starts_with?("y")
                  unless theDate > Date.today + 1.year
                    nextDay = theDate.day
                    exactDate ? nextDay = theDate.day : nextDay =0
                    @event=Event.new(day: nextDay, month: theDate.month, year: theDate.year, title: title, exactDate: false, cat: cat)            
                    newEvents << @event
                  end
                end
          
          end
      return newEvents
  end

  def actionplans
        actionplans = Document.where(patient_id: self.id, code: 1)
        return actionplans
  end




end
