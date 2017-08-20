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
        sql = "SELECT COUNT(id) from Patient where Sex = 'F' and Age > 19 and Age < 66 and Inactive = False and LASTSMEAR > '" + smearDate +"'"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smearDone = row[0]
        sth.drop
        sql = "SELECT COUNT(id) from Patient where Sex = 'F' and Age > 19 and Age < 66 and Inactive = False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @smearTotal= row[0]
        sth.drop

        mamDate = 24.months.ago.to_s(:db)  
        sql = "SELECT COUNT(id) from Patient where Sex = 'F' and Age > 49 and Age < 71 and Inactive = False and LASTMAMMOGRAM> '" + mamDate +"'"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @mamDone= row[0]
        sth.drop
        sql = "SELECT COUNT(id) from Patient where Sex = 'F' and Age > 49 and Age < 71 and Inactive = False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @mamTotal= row[0]
        sth.drop

        lastYear = 1.year.ago.to_s(:db)  
        sql = "SELECT COUNT(id) FROM Patient WHERE Diabetic = True and Inactive= False and DiabetesCycleDate > '" + lastYear +"'"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diabeticCycles = row[0]
        sth.drop
        sql = "SELECT COUNT(id) from Patient WHERE Diabetic = True and Inactive= False"
        puts sql
        sth = dbh.run(sql)
        row= sth.fetch_first
        @diabeticTotal= row[0]
        sth.drop




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



  def getThirdAvailable(dbh,doctor,startDate=Date.today)
            timeNow = DateTime.now

            providerStr = ""
            if doctor != 0
              providerStr =  " AND ProviderID = " + doctor.to_s
            end 
           endDate = startDate + 2.months
           sql =  "SELECT StartDate, StartTime, ApptDuration from Appt WHERE StartDate >= '" + startDate.to_s(:db) + "' AND StartDate < '" + endDate.to_s(:db) + "' " + providerStr + " ORDER BY StartDate, StartTime"
           puts sql
           sth= dbh.run(sql)
           appts=[]

           sth.fetch do |row|
              # genie does a funny thing where the StartTime ddmmyy are wrong, only the time counts !
              # appt duration is in secs and 900 secs = 15 minutes

             t=row[1]
             d=row[0]
             unless d.instance_of?(Date)
              d=Date.strptime(row[0], '%d/%m/%y')
             end
             t=t.change(:year => d.year, :month => d.month,:day => d.day)
 
             appts<<[t, row[2]]

          end
          sth.drop
          available=0
          freeAppt=0
          dateBlocked={}

          if appts.count>0
                    nextAppt = appts[0][0]
                    # freeAppt=nextAppt
                    appts.each do |appt|
                        # is the next appt blank
                            # create Ruby Date from StartDate, StartTime
                            #t = Time.new(1993, 02, 24, 12, 0, 0, "+09:00")
                            t=appt[0]

                            
                            # is this expected appt
                            while t > nextAppt
                                # is this part of an ApptBlock eg Annual Leave
                                # if so, skip to the next day

                                #grades = { "Jane Doe" => 10, "Jim Doe" => 6 }
                              
                                thisDay = Date.new(nextAppt.year,nextAppt.month,nextAppt.day)
                                thisDayKey=thisDay.to_s(:db)

                                
                                unless dateBlocked.key?(thisDayKey)
                                    if thisDay.saturday? or thisDay.sunday?
                                      dateBlocked[thisDayKey] = 1
                                    end
                                end
                                unless dateBlocked.key?(thisDayKey)
                                      if doctor != 0
                                        sql =  "SELECT Id from ApptBlock WHERE StartDate = '" + thisDayKey + "' and ProviderID = " + doctor.to_s
                                        puts sql
                                        sth= dbh.run(sql)
                                        dateBlocked[thisDayKey] = sth.nrows
                                        puts thisDayKey
                                        puts dateBlocked[thisDayKey]
                                        sth.drop
                                      end
                                    
                                end
                                # is not availbale if no other appts on that day. Will always have lunch etc
                                # so are there any other appts on this day
                                # only need to check once per day, so check at 8;30
                                  if dateBlocked[thisDayKey] == 0 and nextAppt.hour == 8 and nextAppt.min == 30



                                     sql =  "SELECT Id from Appt WHERE StartDate = '" + thisDayKey + "'  " + providerStr
                                     puts sql

                                      sth= dbh.run(sql)
                                    
                                      if sth.nrows == 0 
                                            # there are no appts on this day so it is not available
                                          dateBlocked[thisDayKey] = 1
                                          
                                      end
            
                                      sth.drop
                                    
                                end                              



                                if dateBlocked[thisDayKey]==0
                                     available = available + 1
                                     freeAppt = nextAppt unless available > 3
                                     nextAppt = nextAppt + 900.seconds

                                     if nextAppt.hour == 16 and nextAppt.min > 30
                                          
                                          nextAppt = nextAppt + 1.day
                                          nextAppt= nextAppt.change(:hour => 8, :min=>30)
                                     end
                                 else
                                        nextAppt = nextAppt + 1.day
                                        nextAppt= nextAppt.change(:hour => 8, :min=>30)
                                        
                                        
                                 end 
                                 sth.drop
                            end
                            
                            nextAppt = t + appt[1].seconds
                            if nextAppt.hour == 16 and nextAppt.min > 30
                                    
                                    nextAppt = nextAppt + 1.day
                                    nextAppt= nextAppt.change(:hour => 8, :min=>30)
                            end
                            
                            break if available > 3
                    end
          end
          #how many patients are in the queue?
          queue = 0
          if freeAppt != 0  and doctor != 0 

            endTime = freeAppt.hour.to_s + ":" + freeAppt.min.to_s + ":00"
           
            
  
           sql =  "SELECT Id from Appt WHERE Status = 7 AND StartDate >= '" + startDate.to_s(:db) + "'  AND (StartDate < '" + freeAppt.to_s(:db) + "' OR (StartDate = '" + freeAppt.to_s(:db) + "' and StartTime < '"+ endTime + "' )) AND ProviderID = " + doctor.to_s + " AND (Reason = '' or Reason = 'General Chec' or Reason = 'LICENCE' or Reason = 'Immunisation')"
           
          puts sql

          sth= dbh.run(sql)
                                    
          queue = sth.nrows

            
           sth.drop
         end

         queueTotal = 0

           
            
  
           sql =  "SELECT Id from Appt WHERE StartDate >= '" + startDate.to_s(:db) + "' AND ProviderID = " + doctor.to_s + " and PT_Id_FK > 0"
           
          puts sql

          sth= dbh.run(sql)
                                    
          queueTotal = sth.nrows

            
           sth.drop
         


          return [freeAppt,queue,queueTotal]



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
        
         sql = "SELECT Surname,FirstName,FullName,LastSeenDate,LastSeenBy,MobilePhone, EmailAddress, Age, Sex, Id FROM Patient WHERE Age >44 and Age <50 and Inactive= False  ORDER BY Age DESC"   
         puts sql
          sth = dbh.run(sql)
          @no_ass_patients = []
          @ass_patients = []
          @totalCount=0
          @mobileCount=0
          @emailCount=0
          @F49Count=0
          sth.fetch_hash do |row|
              @totalCount+=1
              # now see if that patient has ever had health assessment
              sql2 =  "SELECT ServiceDate, ProviderId FROM Sale WHERE PT_Id_FK =" + row['ID'].to_s + " AND ItemNum = '703'"
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
         while theDate <= endDate

           
            @returnArray=get_charge(dbh,theDate)
            @dateArray <<  @returnArray
            if @returnArray[0]>0
                @clinic_days = @clinic_days + 1
                @total_charge += @returnArray[0]
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