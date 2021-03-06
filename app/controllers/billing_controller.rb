class BillingController < ApplicationController
 require 'csv'

  def index

  end

  def test
      # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
         dbh=connect_array[0]
          params.has_key?(:month) ? month = params[:month] :  month=Date.today.month
          params.has_key?(:year) ? year = params[:year] :  year=Date.today.year
      
          @startDate = Date.new(year.to_i, month.to_i, 1)
          @endDate = @startDate + 1.month


          params.has_key?(:ageUnder) ? @ageUnder = params[:ageUnder] : @ageUnder = 0
          params.has_key?(:ageOver) ? @ageOver = params[:ageOver] : @ageOver = 0
          @items=[]
          @initems=[23,36,44]
          @outitems=[]
          @item=get_bb(dbh,@ageUnder,@ageOver,@startDate.strftime("%Y-%m-%d"),@endDate.strftime("%Y-%m-%d"),@initems,@outitems)
          @charts=[]


          dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
    end
  end

  def oldfax
      thisFax = Fax.new("tlembke","B1ckleB1ckle")
     # @access_token = thisFax.get_token
      #@access_token == "" ? @errMsg = "Log In Fail" : @errMsg = "Worked!"
      theText="
      This is the test document
      This is the second line
      This is the third line
      This is the fourth line
      "
      theFile = "/Users/tlembke/Projects/fax2-api-demo-php/sample.pdf"
      documents = []
      response = thisFax.upload_text(theText)
      documents << response["document_id"]
      response = thisFax.upload_file(theFile)
      documents << response["document_id"]
      dest_number = "61285836542"
      @response=thisFax.send_fax(dest_number,documents)










  end






  def get_token(username,password)

      begin
      endPoint = 
      response = RestClient.post "https://"+username+":" + password + "@api.fax2.com.au/v1/oauth2/token", {grant_type: 'client_credentials'}
        response2=JSON[response.body]
      
          access_token = response2["access_token"] 
        
       
      rescue
         access_token = ""
      end
      return access_token

  end

  def upload_text(access_token,theText)
    theUrl="https://api.fax2.com.au/v1/upload_document"
    # response = RestClient.post(theUrl, {theText.to_json}, {content_type: "text/plain", Authorization: "bearer " + access_token })
    response= RestClient::Request.execute(method: :post, url: theUrl,
                            payload: theText, headers: {content_type: "text/plain; charset=utf-8", Authorization: "bearer " + access_token})
    response2=JSON[response.body]
    return response2


  end

  def upload_file(access_token,theFile)
    theUrl="https://api.fax2.com.au/v1/upload_document"
    begin
    # response = RestClient.post(theUrl, {theText.to_json}, {content_type: "text/plain", Authorization: "bearer " + access_token })
      response= RestClient::Request.execute(method: :post, url: theUrl,
                          payload: {:document => File.new(theFile, 'rb')}, headers: {Authorization: "bearer " + access_token, content_type: "multipart/form-data"})
    #response = RestClient.post( theUrl, {:myfile => File.new(theFile, 'rb')}, headers: {Authorization: "bearer " + access_token, content_type: "multipart/form-data"})
    #response= RestClient::Request.execute(method: :post, url: theUrl,
       #                     payload: {:myfile => File.new(theFile, 'rb')}, headers: {content_type: "mutipart/form-data", Authorization: "bearer " + access_token})


    rescue RestClient::ExceptionWithResponse => err
        response2 = err.response


    end
  
    
  #request = RestClient::Request.new(
   #       :method => :post,
   #       :url => theUrl,
   #       :payload => {
   #         :file => File.new(theFile, 'rb')
   #       },
   #       :headers =>  {content_type: "multipart/form-data", Authorization:  "bearer " + access_token}
          
    #      )      
    #response = request.execute


    response2=JSON[response.body]
    return response2


  end

  def send_fax(access_token,dest_number,documents)
      theUrl="https://api.fax2.com.au/v1/send_fax"
      docText = ""
      documents.each do |document|
          docText = docText + "documents[]=" + document + "&"
      end
      docText = docText + "dest_number=" + dest_number
        response= RestClient::Request.execute(method: :post, url: theUrl,
                            payload: docText, headers: {Authorization: "bearer " + access_token})
    response2=JSON[response.body]
    return response2

  end




  def appointments

    @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]



           
            
  
           sql =  "SELECT Id from Appt WHERE  StartDate >= '" + Date.today.to_s(:db) + "'  and PT_Id_FK > 0"
           
          puts sql

          sth= dbh.run(sql)
                                    
          @overallTotal = sth.nrows

            
           sth.drop

        @overall =  overall3AA(dbh)


        @users = getProviders(dbh)
        #@appt_array = getThirdAvailable(dbh,94)
        #@appts = @appt_array[0]
        #@nextAppt = @appt_array[1]






        dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.json

     end
    

 

  end

   def bookings

     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
        dateTest = Date.today

        @noDays=7
        @bookings =[]
        while @noDays>0
          while dateTest.saturday? or dateTest.sunday?
              dateTest= dateTest + 1.day
           end

           @bookings << getApptsForDay(dbh,dateTest)
           dateTest = dateTest + 1.day
           @noDays = @noDays - 1
        end

        






        dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 

     end
    

 

  end


 

  def paeds
     # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]

          enddate=Date.today.to_s(:db)

          startdate=3.years.ago
          @startdate=startdate.beginning_of_month
          noMonths = (Date.today.year * 12 + Date.today.month) - (startdate.year * 12 + startdate.month)
          @ageunder=5
          @ageover=0
          @items=[]
          @initems=[23,36,44]
          @outitems=[]

          i=0
          while i< noMonths do 
            enddate=startdate + 1.month
            @newitems=get_bb(dbh,@ageunder,@ageover,startdate.strftime("%Y-%m-%d"),enddate.strftime("%Y-%m-%d"),@initems,@outitems)
            @items<<@newitems
            startdate=enddate
            i+=1
          end
          @charts=[]


          dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
    end
  end

    def data
          # get appointments
       @username = session[:username]
       @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]

 
        sql = "SELECT Count(Id) FROM Patient where Patient.Inactive = False "
        sth = dbh.run(sql)
        row= sth.fetch_first
        @patientsTotal = row[0]
        sth.drop

         sql = "SELECT Count(Id) FROM Patient where Patient.Inactive = False and Age > 17"
        sth = dbh.run(sql)
        row= sth.fetch_first
        @patientsAdult = row[0]
        sth.drop


        
        sql = "SELECT Count(CurrentProblem.Id) FROM CurrentProblem, Patient where CurrentProblem.PT_Id_FK = Patient.Id and Patient.Inactive = False "
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diagnosesTotal = row[0]
        sth.drop
        sql = "SELECT Count(CurrentProblem.Id) FROM CurrentProblem, Patient where CurrentProblem.PT_Id_FK = Patient.Id and Patient.Inactive = False and CurrentProblem.ICPCCode = ''"
         puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diagnosesUncoded = row[0]
        sth.drop


        sql = "SELECT DISTINCT Patient.ID FROM Allergy,Patient where Allergy.PT_Id_FK = Patient.Id and Patient.Inactive = False"
        sth = dbh.run(sql)
        @allergiesCount = sth.nrows
        sth.drop

        sql = "SELECT COUNT(Patient.Id) from Patient,PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id  AND  SmokingFreq > 0 and Inactive= False and Age > 17"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smokingRecorded= row[0]
        sth.drop

        sql = "SELECT COUNT(Patient.Id) from Patient,PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id  AND SmokingFreq = 0 and Inactive= False and Age > 17"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smokingUnrecorded= row[0]
        sth.drop

        sql = "SELECT COUNT(Patient.Id) from Patient,PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id  AND SmokingFreq > 3 and Inactive= False and Age > 17"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smokingNon= row[0]
        sth.drop

        sql = "SELECT COUNT(Patient.Id) from Patient,PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id  AND  SmokingFreq > 0 and SmokingFreq <4 and Inactive= False and Age > 17"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smokingCurrent= row[0]
        sth.drop

        sql = "SELECT DISTINCT Patient.Id from Patient,Measurement where Measurement.PT_Id_FK = Patient.ID and Measurement.Weight > 0 and Patient.Inactive = False "
        puts sql
        sth = dbh.run(sql)
        @weightCount = sth.nrows
        sth.drop

        @cp_uploads = get_cp_uploads(dbh)






        

        



        # @users = getProviders(dbh)
        #@appt_array = getThirdAvailable(dbh,94)
        #@appts = @appt_array[0]
        #@nextAppt = @appt_array[1]






        dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
     end


  end

  def log
      @log_contents = File.read('log/appt.log')
  end




  def pip
         # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]

        smearDate = 30.months.ago.to_s(:db)

   # sql = "SELECT COUNT(id) from Patient where Sex = 'F' and Age > 19 and Age < 66 and Inactive = False and LASTSMEAR > '" + smearDate +"'"
     
        sql = "SELECT COUNT(Patient.Id) from Patient, PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id and Sex = 'F' and Age > 19 and Age < 71 and Inactive = False and (LASTHPV > '" + smearDate +"' OR LASTSMEAR > '" + smearDate +"')"
         
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smearDone = row[0]
        sth.drop
        sql = "SELECT COUNT(Patient.Id) from Patient where Sex = 'F' and Age > 19 and Age < 71 and Inactive = False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smearTotal= row[0]
        sth.drop

        mamDate = 24.months.ago.to_s(:db)  
        sql = "SELECT COUNT(Patient.Id) from Patient, PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id and Sex = 'F' and Age > 49 and Age < 71 and Inactive = False and LASTMAMMOGRAM> '" + mamDate +"'"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @mamDone= row[0]
        sth.drop
        sql = "SELECT COUNT(Patient.Id) from Patient where Sex = 'F' and Age > 49 and Age < 71 and Inactive = False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @mamTotal= row[0]
        sth.drop

        lastYear = 1.year.ago.to_s(:db)  
        sql = "SELECT COUNT(Patient.Id) FROM Patient, PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id and Diabetic = True and Inactive= False and DiabetesCycleDate > '" + lastYear +"'"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diabeticCycles = row[0]
        sth.drop
        sql = "SELECT COUNT(Patient.Id) from Patient, PatientClinical WHERE Patient.PTCL_ID_FK = PatientClinical.Id and Diabetic = True and Inactive= False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diabeticTotal= row[0]
        sth.drop

        
        @shs=[]
        @charted_values = []
    
        count=0
        while count < 24
            shsCount = shs(dbh, 0, count.months.ago)
            @shs << shsCount     
            value_h ={"DATE" => count.months.ago.end_of_quarter, "SHS" => shsCount  } 
            @charted_values << value_h
            count = count +3 
            
        end

        @shsusers = getUsersSHS(dbh)

        



        # @users = getProviders(dbh)
        #@appt_array = getThirdAvailable(dbh,94)
        #@appts = @appt_array[0]
        #@nextAppt = @appt_array[1]






        dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
     end
    

  end


    def emails
        
       @username = session[:username]
       @password = session[:password]
      @id=session[:id]
      @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]

        if request.format=="csv"

     
            sql = "SELECT EmailAddress, FirstName, Surname FROM Patient where Inactive = False AND EmailAddress <> ''"
            sth = dbh.run(sql)
            theList= sth.fetch_all
            

            sth.drop

            csv_file = theList.map(&:to_csv).join 
        else
            
             sql = "SELECT Count(Id) FROM Patient where Inactive = False AND EmailAddress <> ''"

            sth = dbh.run(sql)
            row= sth.fetch_first
            @emailCount= row[0]
            sth.drop

            
         
        end 

       

        dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "emails.csv" 
        }
     end


  end


  def shs(dbh,user=0,indexDate = Date.today)
    # this gets the number of shs done in his quarter
    startDate = indexDate.beginning_of_quarter
    endDate = indexDate.end_of_quarter
    userStr = ""
    if user!= 0
      userStr = "AuthorPersonHPII = '" + user.to_s + "' AND "
    end
    sql = "SELECT Count(Id) FROM CDA where " + userStr + "CreationDate >= '" + startDate.to_s(:db) + "' AND CreationDate <= '" + endDate.to_s(:db) + "' AND SentToPCEHR = true"
    puts sql
    sth = dbh.run(sql)
    row = sth.fetch_first
    
    sth.drop

    return row[0] ? row[0] : 0


  end

    def itemcheck
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
        
        @noDays=1

      
          @appts,@nurses =get_all_appts(dbh,@theStartDate)
          @appt_ids=@appts.map {|x| x.values[9]}
          dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end
     
  end


  def pathwaysOld
   require 'net/https'
   require 'uri'


    # Log on
    uri = URI.parse("https://manc.healthpathways.org.au//LoginFiles/Logon.aspx")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth("manchealth", "conn3ct3d")
    @response = http.request(request)
    
end

def pathways
    @searchTerm = params[:q]
    agent = Mechanize.new
    if File.exist?("cookies/yaml")
        agent.cookie_jar.load("cookies.yaml")
    else
      page=agent.get("https://manc.communityhealthpathways.org/LoginFiles/Logon.aspx")
      pathwaysForm = page.form(id: 'form2')
      pathwaysForm.txtUserName = 'manchealth'
      pathwaysForm.txtPassword = 'conn3ct3d'
     
      @page=agent.submit(pathwaysForm,pathwaysForm.buttons.first)
      agent.cookie_jar.save("cookies.yaml", session: true)
    end
    #page=agent.get("https://manc.healthpathways.org.au/TOC.htm")
    #contents = page.parser.xpath("//div[@id = 'tocContent']")

    #@contArray = contents.to_s.scan(/<a id="(\S+)" href="(\S+)"><span class="(\S+)">(.+)<\/span>/)
    # @page=agent.get("https://manc.healthpathways.org.au/search/search.aspx?zoom_per_page=200&zoom_query=" + @searchTerm)
    @page=agent.get("https://manc.communityhealthpathways.org/search?q=" + @searchTerm)
    
    #@searchResult = page.css(".results").text






end

  def get_all_appts(dbh,theStartDate = Date.today )
          theDay=theStartDate.to_s(:db)
          
          sql = "SELECT Name, Note, ProviderID, ProviderName, Charge, Reason, StartDate, StartTime, Status, PT_Id_Fk FROM Appt WHERE StartDate = '" + theDay + "' and PT_Id_FK <> 0 ORDER BY ProviderID, StartTime"
          puts sql
         

          sth = dbh.run(sql)



               
          appts=[]
          nurses=[]
          sth.fetch_hash do |row|

            row['WARNING'] = false
            items,bbItemCount,bbCount = get_item_numbers(dbh, row['PT_ID_FK'].to_s, theDay)
            row['ITEMS'] = items
            buttonText = parse_plan(row['NAME'],row['ITEMS'])
            row['NAME'] = row['NAME'] + buttonText
            if buttonText != ""
                row['WARNING'] = true
            end
            row['NAME'] = parse_numbers(row['NAME'],row['ITEMS'])
            if row['NAME'].include?("danger")
                row['WARNING'] = true
            end

            row['FEETYPE'], row['INCENTIVE'] = getFeeType(dbh,row['PT_ID_FK'].to_s)
            row['FEETYPE'] = "DVA" if row['FEETYPE'] == "Veterans Affairs"
            row['FEETYPE'] = "Pte" if row['FEETYPE'] == "Private"
            row['MISSBB'] = 0
            if row['INCENTIVE']
              row['MISSBB'] = bbItemCount - bbCount
          
            end
            if row['MISSBB'] != 0
              row['WARNING'] = true
            end
            appts << row
            if row['PROVIDERID'] == 89 or row['PROVIDERID'] == 87
                nurses[row['PT_ID_FK']] = row['NAME']
            else
                row['PLAN'] = get_plan(dbh,row['PT_ID_FK'],row['PROVIDERID'],theDay, items)
            end
            if row['PLAN'] and row['PLAN'].include?("btn-danger")
                row['WARNING'] = true
            end


          end

          sth.drop



          return appts,nurses

  end

    def get_plan(dbh,patient,provider,theDate,items=[])
            sql = "SELECT History, Examination, Diagnosis, Plan FROM Consult WHERE PT_Id_FK = " + patient.to_s + " and ConsultDate = '" + theDate + "' and DoctorID = " + provider.to_s
          
            puts sql
            planText=""
            sth = dbh.run(sql)
             sth.fetch do |row|
              planText = planText + row[0] +row[1] + row[2] + row[3]
            end
            sth.drop
            if items.count>0
              planText=parse_plan(planText,items) + planText
            end

            return planText


 end

  def getFeeType(dbh,patient)
          sql = "SELECT Age, AccountType, DvaNum, HccPensionNum FROM Patient where Id = " + patient
 
          puts sql
         

          sth = dbh.run(sql)
          row= sth.fetch_first
           feeType = row[1]
           dvaNum = row[2]
           hccPensionNum = row[3]
           age= row[0].to_i
          sth.drop
          incentive = false
          
          if dvaNum != ""
              incentive = true
          end
          if hccPensionNum != ""
              incentive = true
          end 
          if age < 16
              incentive = true
          end             
          return feeType,incentive

  end

  def parse_numbers(theText,items)
    #theeText=theText.gsub(/\d+/, '{\0}')
    # reaplce 732 x 2 with 732 732

    theText= theText.gsub(/(\d+) x 2/,'\1 \1')
    theText= theText.gsub(/\d+/) { |num| number_button(num, items)}

    return theText

  end

  def number_button(num,items)

      #buttonText = "<button class='btn btn-sm'>" + num + "</button>"
      if num.to_i < 9 
        return num
      else
         buttonText= plan_button(num,[num],items)
      end
      return buttonText
  end

  def parse_plan(planText,items)
          buttonText=""
          plan = planText.downcase
          if items.count>0
            if plan.include? "ecg"
                buttonText = plan_button("ECG",["11700"],items) + buttonText

            end
            if plan.include? "rft" or plan.index(/\bspiro\b/) or plan.include? "spirometry"
               buttonText = plan_button("RFT",["11505","11506"],items) + buttonText
            end
            if plan.include? "biopsy" or plan.index(/\bbx\b/)
                  buttonText = plan_button("Biopsy",["30071"],items) + buttonText
                
            end
            if plan.include? "bhcg"
                 buttonText = plan_button("BHCG",["73806"],items) + buttonText
            end

          end
          return buttonText

  end

  def plan_button(theText,itemNumbers,items)
        buttonColor = "danger"
        itemNumbers.each do | itemNumber |
          buttonColor = "success" if items.include?([itemNumber, true]) or items.include?([itemNumber, false]) 
        end
        returnText = ("<button class='btn btn-sm btn-" + buttonColor + "'>" + theText + "</button>").html_safe
        return returnText
  end


    def get_all_seen_patients(dbh,theStartDate = Date.today )
          theDay=theStartDate.to_s(:db)
          
          sql = "SELECT Surname,FirstName,LastSeenDate,LastSeenBy,Id FROM Patient where LastSeenDate = '"+theDay +"' "
 
          puts sql
         

          sth = dbh.run(sql)
               
          patients=[]
          sth.fetch_hash do |row|

            patients << row
          end

          sth.drop



          return patients

  end


    def get_item_numbers(dbh,patient,theDay)
         
          
          sql = "SELECT ItemNum, BatchNum FROM Sale where PT_Id_Fk = "+ patient +" and ServiceDate = '" + theDay +"'"
 
          puts sql
         
          
        
         

          sth = dbh.run(sql)
               
          items=[]
          bbCount=0
          bbItemCount=0
          sth.fetch_hash do |row|
            bb=false
            row['BATCHNUM'] !="" ? bb=true : bb=false

            items << [row['ITEMNUM'], bb]
            if bb
              if row['ITEMNUM'] == '10991' or row['ITEMNUM'] == '10990'
                  bbCount = bbCount + 1
              else
                  bbItemCount = bbItemCount + 1
              end
           end

          end

          sth.drop



          return items,bbItemCount,bbCount

  end

    def getUsersSHS(dbh)

          sql = "SELECT  Name, Id, HPII FROM Preference  where Inactive = False and ProviderType = 2 and ProviderNum <> '' ORDER BY Surname"
          puts sql
         

          sth = dbh.run(sql)
               
          users=[]
          sth.fetch_hash do |row|
            shsDone= shs(dbh,row['HPII'])
            shsDoneLast = shs(dbh,row['HPII'],3.months.ago)
           
            users << [row['NAME'],row['HPII'], shsDone, shsDoneLast]
          end

          sth.drop
          return users

  end






  def getProviders(dbh)

          sql = "SELECT  Name, Id FROM Preference  where Inactive = False and ProviderType = 2 and ProviderNum <> '' ORDER BY Surname"
          puts sql
         

          sth = dbh.run(sql)
               
          users=[]
          sth.fetch_hash do |row|
            thirdAvailableArray= getThirdAvailable(dbh,row['ID'])
           
            users << [row['NAME'],row['ID'], thirdAvailableArray[0],thirdAvailableArray[1],thirdAvailableArray[2]]
          end

          sth.drop
          return users

  end



  

  def getApptsForDay(dbh,theDate = Date.today)
    # we are interested in routines booked, annexe booked, acute booked, acute not booked, excisions booked, available routine
     # 

     sql = "SELECT Count(Id) FROM Appt WHERE StartDate = '" + theDate.to_s(:db) +"' and PT_Id_FK <> 0"
     puts sql
     sth = dbh.run(sql)
     row= sth.fetch_first
     @total_appts = row[0]
     sth.drop


     sql = "SELECT Count(Id) FROM Appt WHERE StartDate = '" + theDate.to_s(:db) +"' and (Reason = '' or Reason = 'General Chec' or Reason = 'LICENCE' or Reason = 'Immunisation' or Reason = '************' or Reason = 'follow ups')"
     puts sql
     sth = dbh.run(sql)
     row= sth.fetch_first
     @routines = row[0]
     sth.drop


     sql = "SELECT Count(Id) FROM Appt WHERE StartDate = '" + theDate.to_s(:db) +"' and Reason = 'Acute Only' and PT_Id_FK = 0 "
     puts sql
     sth = dbh.run(sql)
     row= sth.fetch_first
     @acutes = row[0]
     sth.drop

    sql = "SELECT Count(Id) FROM Appt WHERE StartDate = '" + theDate.to_s(:db) +"' and Reason = 'Acute Only' and PT_Id_FK <> 0 "
     puts sql
     sth = dbh.run(sql)
     row= sth.fetch_first
     @acutes_booked = row[0]
     sth.drop
     if @acutes_booked == ""
      @acutes_booked = 0
    end


     # here's the rub - how many doctors are working
     sql = "SELECT  Id FROM Preference  where Inactive = False and ProviderType = 2 and ProviderNum <> ''"
     puts sql
     sth = dbh.run(sql)
         
    users=[]
    sth.fetch_hash do |row|
     
      users << row['ID']
    end
    sth.drop

    # a user is working if that have more than 5 appts that day - lunch, Mrs B etc
     userCount=0
     freeAppt = 0
     users.each do |user|
                  sql =  "SELECT DISTINCT StartTime from Appt WHERE StartDate = '" + theDate.to_s(:db) + "'  AND ProviderID = " + user.to_s + " AND Reason <> 'ON CALL WEEKEND'"
                  puts sql
                  sth = dbh.run(sql)
                  apptsTotal = sth.nrows
                  sth.drop
                  if  apptsTotal > 4
                      userCount +=1 
                      freeAppt = freeAppt + countBlanks(dbh,user,theDate)
                      puts "done"

                  end
                  

                
      end
      puts "next day"


     return [theDate, userCount, freeAppt, @total_appts,@routines, @acutes, @acutes_booked]
               
          


  end

  def countBlanks(dbh,user,theDate)
         sql =  "SELECT StartDate, StartTime, ApptDuration from Appt WHERE StartDate = '" + theDate.to_s(:db) + "' AND ProviderID = " + user.to_s + " ORDER BY StartTime"
           puts sql
           sth= dbh.run(sql)
           appts=[]

           sth.fetch do |row|
              # genie does a funny thing where the StartTime ddmmyy are wrong, only the time counts !
              # appt duration is in secs and 900 secs = 15 minutes

             t=row[1]

             
             t=t.change(:year => theDate.year, :month => theDate.month,:day => theDate.day)

             appts<<[t, row[2]]

          end
          sth.drop
          freeAppt=0

          if appts.count>0
                    nextAppt = appts[0][0]
                    # freeAppt=nextAppt
                    appts.each do |appt|
                        # is the next appt blank
                            
                            t = appt[0]
                            
                            # is this expected appt
                            
                            while t > nextAppt

                                     freeAppt = freeAppt + 1
                                     puts freeAppt
                                     nextAppt = nextAppt + 900.seconds
                            end
                            
                            nextAppt = t + appt[1].seconds

                    end


          end
          puts "4:30"
          while nextAppt.hour < 16  or (nextAppt.hour == 16 and nextAppt.min < 45)
                  
                  freeAppt = freeAppt+1
                  puts freeAppt
                  nextAppt = nextAppt + 900.seconds
                  break if freeAppt>100
          end
          
          return freeAppt


  end

  def overall3AA(dbh,startTime=Time.now)
    # this requires a different approach - going through user by user
    # get startDate and time
    

     sql = "SELECT  Id FROM Preference  where Inactive = False and ProviderType = 2 and ProviderNum <> ''"
     puts sql
         

    sth = dbh.run(sql)
         
    users=[]
    sth.fetch_hash do |row|
     
      users << row['ID']
    end

    sth.drop
    
    # convert start time to next 15 minute spot
    array = startTime.to_a
    quarter = ((array[1] % 60) / 15.0).floor
    array[1] = (quarter * 15) % 60
    nextAppt = Time.local(*array) + (quarter == 4 ? 3600 : 0)
    while nextAppt.saturday? or nextAppt.sunday?
                nextAppt = nextAppt + 1.day
                nextAppt= nextAppt.change(:hour => 8, :min=>15)
    end

    apptCount = 0
    prevCheckDate=0

    while apptCount <3

            nextAppt = nextAppt + 900.seconds

          # If after 4.30 pm will need to be 8.30 next weekday



          if nextAppt.hour > 16 or (nextAppt.hour == 16 and nextAppt.min > 30)
                
                nextAppt = nextAppt + 1.day
                while nextAppt.saturday? or nextAppt.sunday?
                      nextAppt = nextAppt + 1.day
                end
                
                nextAppt= nextAppt.change(:hour => 8, :min=>30)
          end
          nextDate = Date.new(nextAppt.year,nextAppt.month,nextAppt.day)
          if prevCheckDate==0 or prevCheckDate != nextDate            
            # check which users are away to speed things up
              prevCheckDate  = nextDate
              userHere={}
              users.each do |user|
                  sql =  "SELECT Id from Appt WHERE StartDate = '" + nextDate.to_s(:db) + "'  AND ProviderID = " + user.to_s
                  puts sql
                  sth = dbh.run(sql)
                  apptsTotal = sth.nrows
                  sth.drop
                  userHere[user] = apptsTotal
                  puts apptsTotal
               end

          end


      


          # how many providers have a free appointment at this time
          users.each do |user|
              if userHere[user] >0 and userHere[user]< 34
                  apptCount = apptCount + checkFreeAppt(dbh, user, nextAppt)
              end

          end
          

      end
      return nextAppt
    



  end

  def checkFreeAppt(dbh, doctor, nextAppt)
          # does this doctor have a free appt at this time
          # 1 does he have an appt already booked?
           apptCount=0
           apptDate= Date.new(nextAppt.year,nextAppt.month,nextAppt.day)

           apptTime  = nextAppt.hour.to_s + ":" + nextAppt.min.to_s + ":00"
            prevAppt = nextAppt - 15.minutes
            prevApptTime  = prevAppt.hour.to_s + ":" + prevAppt.min.to_s + ":00"
            prevprevAppt = prevAppt - 15.minutes
            prevprevApptTime  = prevprevAppt.hour.to_s + ":" + prevprevAppt.min.to_s + ":00"

            sql =  "SELECT Id from Appt WHERE StartDate = '" + apptDate.to_s(:db) + "' and (StartTime ='" + apptTime + "' or (StartTime ='" + prevApptTime + "' and ApptDuration > 900) or (StartTime ='" + prevprevApptTime + "' and ApptDuration > 1800)) AND ProviderID = " + doctor.to_s
            puts sql
            sth= dbh.run(sql)
            if sth.nrows == 0 
                    apptCount=1
            end
            sth.drop

            
           
 
           


           return apptCount



  end

    def coc(dbh)
         # get appointments
                # step one - get all patients who are diabetic
        
         sql = "SELECT Id FROM Patient WHERE Diabetic = True and Inactive = False"   
         puts sql
          sth = dbh.run(sql)
          @diabetics=sth.nrows

          @cocCount=0
          sth.fetch do |row|
              # now see if that patient has ever had health assessment
              sql2 =  "SELECT ServiceDate FROM Sale WHERE PT_Id_FK =" + row[0].to_s + " AND (ItemNum = '2517' or ItemNum ='2521') order by ServiceDate DESC"
              sth2 = dbh.run(sql2)
              row2 = sth2.fetch_first
                if sth2.nrows > 0 and row2[0] > 1.year.ago
                @cocCount+=1
              end
              
              sth2.drop
       

          end
          sth.drop
          lastYear = 1.year.ago

         sql = "SELECT Id FROM Patient WHERE Diabetic = True and Inactive= False and DiabetesCycleDate > '" + lastYear.to_s(:db) +"'"
         puts sql
          sth = dbh.run(sql)
          @diabeticCycles=sth.nrows



    return[@diabetics,@cocCount,@diabeticCycles]

  end

    

  def assessments
         # get appointments

     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
                # step one - get all patients aged 45-49, orderd pckwards by age
         
         
          params[:age] ? @age= params[:age].to_i : @age = 75
          # ages arent updated automatically in Genie so have to resort to DOB instead of this
          #ageText = " AGE > 74 and AGE < 110"
          #if @age != 75
          #   ageText = " AGE > 44 and AGE < 50"
          #end

          ageText = " DOB < '" + 75.years.ago.to_date.to_s(:db) + "' AND DOB IS NOT NULL "
          if @age != 75
             ageText = " DOB  > '" + 50.years.ago.to_date.to_s(:db) + "' AND DOB < '" + 45.years.ago.to_date.to_s(:db) +"'"
          end

         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,MobilePhone, EmailAddress, Age, DOB, Sex, Id FROM Patient WHERE " + ageText + " and Inactive= False  ORDER BY DOB"   
         puts sql
          sth = dbh.run(sql)
          @no_ass_patients = []
          @ass_patients = []
          @totalCount=0
          @mobileCount=0
          @emailCount=0
          @F49Count=0
          sth.fetch_hash do |row|
            if row['DOB']
                  @totalCount+=1
                  # now see if that patient has ever had health assessment
                  sql2 =  "SELECT ServiceDate, ProviderId FROM Sale WHERE PT_Id_FK =" + row['ID'].to_s + " AND ItemNum = '703'"
                  # if age = 75 then health assessment date has to have been in last 12 month
                   if @age == 75
                        sql2 = sql2 + " and ServiceDate > '" + 1.year.ago.to_s(:db) +"'"
                  end
                  puts sql2
                  sth2 = dbh.run(sql2)
                  if sth2.nrows > 0
                      row2 = sth2.fetch_first
                    
                         #this patient has had a health assessment
                        row[:PROVIDERID] = row2[1]
                        row[:SERVICEDATE] = row2[0]
                        @ass_patients << row
                      
                       
                  else
                      # this patient has not had a health assessment
                      #if row["LASTSEENDATE"]
                       # row["LASTSEENDATE"]= row["LASTSEENDATE"].to_date
                      #end
                      @no_ass_patients << row
                      if row["MOBILEPHONE"] != "" and row["MOBILEPHONE"] != "no"
                        @mobileCount+=1
                      end
                      if row["EMAILADDRESS"] != ""
                        @emailCount+=1
                      end
                      if row["AGE"] == 49
                        @F49Count+=1
                      end
                    end

                    sth2.drop
              end
              
              
       

          end
          sth.drop



          dbh.disconnect
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
    end

  end


   def cst
         # get appointments

     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
        dbh=connect_array[0]
                
         
         
          params[:age] ? @age= params[:age].to_i : @age = 75
          # ages arent updated automatically in Genie so have to resort to DOB instead of this
          #ageText = " AGE > 74 and AGE < 110"
          #if @age != 75
          #   ageText = " AGE > 44 and AGE < 50"
          #end

          ageText = " SEX = 'F' AND DOB IS NOT NULL AND DOB >'" + 75.years.ago.to_date.to_s(:db) + "' AND DOB < '" + 25.years.ago.to_date.to_s(:db) + "' "
          hpvText =  " ((LastSmear IS NULL or LastSmear < '" + 2.years.ago.to_date.to_s(:db) + "') AND ( LastHPV IS NULL OR LastHPV < '" + 5.years.ago.to_date.to_s(:db) + "'))" 

         

         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,LastSmear,LastHPV,MobilePhone, EmailAddress, DOB,  Patient.Id, NoHpvRecall FROM Patient,PatientClinical where Patient.PTCL_ID_FK = PatientClinical.Id  AND  Inactive = FALSE AND " + ageText + " AND " + hpvText + " AND NoHpvRecall = FALSE ORDER BY LastHPV"   
         puts sql
          sth = dbh.run(sql)
          @hpv_count = sth.nrows

          @hpv_patients = sth.fetch_all


          sth.drop



          dbh.disconnect
     
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
    end

  end

  def cpp
  	 # get appointments
  	 @username = session[:username]
  	 @password = session[:password]
     @id=session[:id]
     @name=session[:name]

  	 connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
    	  dbh=connect_array[0]
    	  @cpp = get_cpp(dbh)
    	  csv_file = make_csv(@cpp)
          dbh.disconnect
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]
  				redirect_to  action: "login"
  	 end

  	 respond_to do |format|
        format.html 
        format.csv { 
     	   send_data csv_file, filename: "billing.csv" 
        }
    end
  end


  def express
    # get appointments
     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)
          dbh=connect_array[0]
         @dateArray=[]
         startDate=Date.new(2017,1,1)
         endDate=Date.today
         theDate=startDate
         @total_charge=0
         @clinic_days = 0
         @charted_values=[]
         while theDate <= endDate

           
            @returnArray=get_charge(dbh,theDate)
            @dateArray <<  @returnArray
            if @returnArray[0]>0
                @clinic_days = @clinic_days + 1
                @total_charge += @returnArray[0]
                value_h ={"DATE" => theDate, "SUM" => @returnArray[0].round  } 
                @charted_values << value_h


            end
            theDate = theDate + 1.day
         end
         dbh.disconnect
         






          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

     respond_to do |format|
        format.html 
        format.csv { 
         send_data csv_file, filename: "billing.csv" 
        }
      end
    end

    def get_charge(dbh,startdate)
           sql =  "SELECT Charge from Appt WHERE StartDate = '" + startdate.to_s(:db) +"' and ProviderID = 75"
           puts sql
           sth= dbh.run(sql)
           daily_charge=0
           count=0
          sth.fetch do |row|
            charge=row[0].to_s.gsub(/[$,]/,'').to_f
            daily_charge+=charge
            count = count+1
          end
          sth.drop

          
          return [daily_charge,count]



    end


         

    def get_bb(dbh,ageunder,ageover,startdate,enddate,initems,outitems)

          dateString = " AND Sale.ServiceDate >= '" + startdate + "' and Sale.ServiceDate < '" + enddate +"' " 
          ageString=""
          if ageunder!=0 or ageover !=0
            ageString += " AND Patient.age <= "+ ageunder.to_s
          end
  
          if ageover !=0
            ageString += " AND  Patient.age >= "+ageover.to_s + " "
          end

          inItemsString = ''
          if initems.count>0
            inItemsString =" AND ("
            i=0
            initems.each do |initem |
                inItemsString += "Sale.ItemNum  = '" + initem.to_s + "' "
                i=i+1
                if i<initems.count
                    inItemsString += " OR "
                end
            end
            inItemsString += ") "
          end
          outItemsString = ''
          if outitems.count>0
            outitems.each do |outitem |
                outItemsString += "AND Sale.ItemNum  <> '" +outitem.to_s + "' "
            end
          end
          sql = "SELECT Sum(Fee) as SumTotal, Count(Sale.Id) as CountTotal FROM Sale,Patient WHERE  Patient.Id = Sale.PT_Id_FK  " + dateString + ageString  + inItemsString + outItemsString
          puts sql
 
         

          sth = dbh.run(sql)
          returnArray=[]
          sth.fetch do |row|
            returnArray[0]=row[0].to_i.round(2)
            returnArray[1]=row[1].to_i
          end
          sql = "SELECT  Sum(Fee) as SumTotal, Count(Sale.Id) from Sale, Patient where Sale.PT_Id_FK = Patient.Id  and Sale.BatchNum <> '' " + dateString +  ageString  + inItemsString + outItemsString
          puts sql
 
         

          sth = dbh.run(sql)
          sth.fetch do |row|
            returnArray[2] = row[0].to_i.round(2)
            returnArray[3]=row[1].to_i
      
          end
          # 1 = SumTotal
          # 2 = Count
          # 3 = SumTotalBB
          # 4 = CountBB



          return returnArray


  end


  def get_paeds_items(dbh,age,startdate,enddate)
          today=Date.today.to_s(:db)
          lastyear=1.year.ago.to_s(:db)
          sql = "SELECT DISTINCT(Sale.PT_Id_FK), Patient.Fullname, Patient.DvaNum FROM Sale, Patient where Patient.Id = Sale.PT_Id_FK  and Sale.ServiceDate > '" + lastyear + "'  AND (Sale.ItemNum = '721' or Sale.ItemNum = '723' or Sale.ItemNum ='732')"
          puts sql
 
         

          sth = dbh.run(sql)
          



  end


 # get patients being managed under care plan and see if they have had a SHS upload
 def get_cp_uploads(dbh)
          today=Date.today.to_s(:db)
          lastyear=1.year.ago.to_s(:db)
          sql = "SELECT DISTINCT(Patient.Id) FROM Patient,Sale where Patient.Id = Sale.PT_Id_FK  and Sale.ServiceDate > '" + lastyear + "'  AND Patient.Inactive = False and (Sale.ItemNum = '721' or Sale.ItemNum = '723' or Sale.ItemNum ='732')"
          puts sql
 
         

          sth = dbh.run(sql)
          cp_total = sth.nrows
          cp_uploads=0
          sth.fetch do |row|


                sql2 = "SELECT Count(Id) FROM CDA where SentToPCEHR = true and PT_Id_FK = " + row[0].to_s
                puts sql2
                sth2 = dbh.run(sql2)
                row2 = sth2.fetch_first
                if row2[0].to_i > 0
                    cp_uploads += 1
                end
                sth2.drop
           end
    
           sth.drop

        return [cp_total, cp_uploads]
          

  end


 # get patients being managed under care plan and their total billing last 12 months
 def get_cpp(dbh)
          today=Date.today.to_s(:db)
          lastyear=1.year.ago.to_s(:db)
          sql = "SELECT DISTINCT(Sale.PT_Id_FK), Patient.Fullname, Patient.DvaNum FROM Sale, Patient where Patient.Id = Sale.PT_Id_FK  and Sale.ServiceDate > '" + lastyear + "'  AND (Sale.ItemNum = '721' or Sale.ItemNum = '723' or Sale.ItemNum ='732')"
          puts sql
 
         

          sth = dbh.run(sql)
          cpp=[]
          sth.fetch do |row|
          	          sql = "SELECT Sum(Fee) as SumTotal, Sum(Rebate) as RebateTotal FROM Sale WHERE PT_Id_FK = " + row[0].to_s + " AND ServiceDate > '" + 1.years.ago.to_s(:db) + "'"
          			  puts sql
      				  sth2 = dbh.run(sql)
               
          			  invoices=sth2.fetch_hash
          			  dva=""
          			  if row[2] != ""
          			  		dva="X"
          			  end
          			  cpp<<[row[0].to_i, row[1], dva, invoices['SumTotal'].to_i,invoices['RebateTotal'].to_i]
          			  sth2.drop

          end


               


          sth.drop



          return cpp
          

  end

  def make_csv(cpps)
  	  csv_string= CSV.generate do |csv|
      	csv << ['patient_id','name','dva','bill_total','rebate']
        cpps.each do |cpp|
        	csv << cpp
      	end
      end
    
    return csv_string

  end



end