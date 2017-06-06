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