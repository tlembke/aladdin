class ApplicationController < ActionController::Base
  require 'odbc'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login, :except => [:login,:error]
  before_filter :populate_registers



 def populate_registers
  @registersAll = Register.all
 end

  config.time_zone = 'Sydney'




  def require_login
      if session[:username] and Time.current < session[:expires_at]
         session[:expires_at] = Time.current + 60*60
      else
        if session[:expires_at] && Time.current >= session[:expires_at]
        	   flash[:alert] = "Session expired due to inactivity"
        end
        redirect_to controller: "genie", action: "login"
      end
  end


def connect
      username=session[:username]
      password=session[:password]
      error_code=0
      dbh=nil
      begin
      dsns= ODBC.datasources
      dsns.each do |dsn|
            puts dsn.name
          end
      dsn_name= dsns[0].name
      puts "Connecting to " + dsn_name
      rescue
      error_code=1
      #redirect_to controller: "genie", action: "login"
      end
      begin
        dbh=ODBC.connect(dsn_name,username,password) 
      rescue
        # ["08004 (1109) Server rejected the connection:\nOn SQL Authentication failed.\r"]
        if ODBC.error[0].include? "Authentication failed"
          error_code = 2
          #redirect_to({controller: "genie", action: "login"}, notice: "Username / password failed")
        else
          error_code=3
        #redirect_to({controller: "genie", action: "login"}, notice: ODBC.error[0])
        end
      error_msg=ODBC.error[0]
      else
        dbh.use_time = true
      end
      # logged in

      
      return [dbh,error_code,error_msg]

   end

    def get_odbc
        begin
          dsn_file = File.read("/Library/ODBC/odbc.ini")
          rescue StandardError=>e
          text = "Cound not read /Library/ODBC/odbc.ini     "+ e.to_s
        else
          match1=dsn_file.match /^Server[\s]*=[\s]*(.*)/
          match2=dsn_file.match /^Port[\s]*=[\s]*(.*)/
          if (match1 && match2)
            text= "Server = "+match1[1]+":"+match2[1]
          else
            text="Unable to determine server/port in /Library/ODBC/odbc.ini"
          end
        end
        return text
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





    def get_macros
    m = HashWithIndifferentAccess.new #=> {}
    m['b'] = "Blood test"
    m['bf'] = "Blood test (fasting)"
    m['p'] = "Phone"
    m['pm'] = "Phone me"
    m['r'] = "Make an appointment with me"
    m['a'] = "Make an appointment"
    m['am'] = "Make an appointment with"
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
    #keys.each do |short|
      # re="^[@-]"+short+"(.*)"

      #re ="^-(\s?\S\S?\s+)?(.*)"
      
      while (task1=plan.match /^-(\s?\S\S?\s+)?(.*)/ ) do
        if task1
          # ok, we have a match
          # if there is no macro, don't replace
          exp=""
          if task1[1]
            exp=task1[1]
            short=exp.strip
            if macros[short]
              exp=macros[short]+" "
            end
          end
          task=exp+task1[2]
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
          short=""
          # and remove task from plan
          plan=plan.sub task1[0],'' 
          plan=plan.strip
        end
      # end
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





  



end