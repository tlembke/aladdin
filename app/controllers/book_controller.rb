class BookController < ApplicationController
	skip_before_filter :require_login
	require "base64"
  require 'icalendar'


  def index2
 

    
     params[:mode]=="v" ? @mode="v" : @mode="h"

     params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

  end



def show_appt_2
    
     # get appointments
     @username = Pref.aladdinuser
     @password = Pref.decrypt_password(Pref.aladdinpassword)
     @websender = Pref.websender
     @webpassword = Pref.decrypt_password(Pref.webpassword)

     connectionId = getConnectionId(@websender,@webpassword)

     params[:action] = ""


     



     connect_array=connect(@username,@password)
     @error_code=connect_array[1]

     
     @preventPast=true

     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)


   
   
     elsif params[:day] != "false" and params[:month] != "false" and params[:year] != "false"

                @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
     else
        @theStartDate=Date.today
    end
    if @theStartDate > Date.today + 6.weeks
        @theStartDate=Date.today
        flash[:notice] = "Booking only available for up to 6 weeks from now. Sorry"
    end

  params[:mode]=="v" ? @mode="v" : @mode="h"

     params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

    

    

 

    
     if (@error_code==0)
        dbh=connect_array[0]

        #loadSlots(dbh,@theStartDate,1)

        @doctors= get_users_ajax


        # temp
        #@doctors=[["Josh Kingston",91,91],["Jimmy Chiu",8,8],["Mike Davis",96,96]] # for testing only
        #@doctors=[["Josh Kingston",91,91]] # for testing only
        @noCols = 3
    
        @displayCount=3
        @startCode=@theStartDate.month*100 + @theStartDate.day
      #theFinishDate = @theStartDate + @noDays.days
        @appointments=[]

      

        
        @dateCodes=[] #to store the relevant days
        @nextAvailable =[] #to store the next available when none found
        
        firstPass = true # to fill @dateCodes once each pass of days
        @doctorsFreesCount=[] # how many free appointments available
        @doctors=[] # a tenproary bypass of below
        @doctors.each do |doctor|
           
                    i=0
                    
                    
                   @thisDate=@theStartDate
         
                   @appointments[doctor[1]]=[]
                   freesCount = 0
                   while i < @noDays
                        while @thisDate.saturday? or @thisDate.sunday?
                                @thisDate = @thisDate + 1.day
                        end
                       @thisCode=@thisDate.month*100 + @thisDate.day
                        @dateCodes<< [@thisCode,@thisDate] if firstPass

                        freeAppts = []

                        #apptArraySimple = findFrees(dbh,doctor[2],@thisDate)
                        apptArraySimple = findFreesWeb(connectionId,doctor[1],@thisDate)
              
                        apptArraySimple.each_with_index do |apptTime,j|
                            single=1
                            if j < apptArraySimple.length - 1 
                             
                              single =2 if apptTime[0] + 900.seconds== apptArraySimple[j+1][0]

                            end
                            apptCode = apptTime[0].hour * 100 + apptTime[0].min
                            freeAppts << [apptCode, single,apptTime[1]]
                          
                        end

                          # @appointments[doctor[2]][@thisCode]=findFrees(dbh,doctor[2],@thisDate)

                            @appointments[doctor[1]][@thisCode] = freeAppts
                            freesCount = freesCount + @appointments[doctor[1]][@thisCode].length
                         
                            @thisDate = @thisDate + 1.day

                            i=i+1
                          
                  end
                       @doctorsFreesCount[doctor[1]] = freesCount

                       if freesCount == 0
                        # there are no availabla appitmtnets in those days
                        #when is the next?
                          
                        #@nextAvailable[doctor[2]]=getThirdAvailable(dbh,doctor[2],@theStartDate,1,Date.today + 6.weeks)[0]
                        @nextAvailable[doctor[1]]=getNextWeb(connectionId,doctor[1],@theStartDate,Date.today + 8.weeks)
                       end

              
                       firstPass = false


             end

          dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
     

     end
     
    #end # temp bypass
   
      closeConnectionId(connectionId)

      render partial: "show_appt"
  end



  def index
           #rename to show_appt
        	 # get appointments


          updateSlots

          params[:mode]=="v" ? @mode="v" : @mode="h"

          params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3


           params[:action] = ""



           
           @preventPast=true

           if params[:date] 
              @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)


         
         
           elsif params[:day] != "false" and params[:month] != "false" and params[:year] != "false" and params[:day] != nil and params[:month] != nil and params[:year] != nil
                     
                      @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
           else
              @theStartDate=Date.today
          end
          if @theStartDate > Date.today + 6.weeks
              @theStartDate=Date.today
              flash[:notice] = "Booking only available for up to 6 weeks from now. Sorry"
          end

        params[:mode]=="v" ? @mode="v" : @mode="h"

           params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

    

    

 



    	  # @doctors= get_users_ajax
        #@doctors = Provider.where(online: true).all
        @doctors = Provider.where(genie_id: 91).all
    	  # temp
    	  #@doctors=[["Josh Kingston",91,91],["Jimmy Chiu",8,8],["Mike Davis",96,96]] # for testing only
    	 # @doctors=[["Josh Kingston",91,91]] # for testing only
        @noCols = 3
    
    	  @displayCount=3
    	  @startCode=@theStartDate.month*100 + @theStartDate.day


        #render partial: "show_appt"
  end

   def show_appt_back_up
     # get appointments
     @username = Pref.aladdinuser
     @password = Pref.decrypt_password(Pref.aladdinpassword)
     @websender = Pref.websender
     @webpassword = Pref.decrypt_password(Pref.webpassword)

     connectionId = getConnectionId(@websender,@webpassword)

     params[:action] = ""


     




     connect_array=connect(@username,@password)
     @error_code=connect_array[1]

     
     @preventPast=true

     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)


   
   
     elsif params[:day] != "false" and params[:month] != "false" and params[:year] != "false"

                @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
     else
        @theStartDate=Date.today
    end
    if @theStartDate > Date.today + 6.weeks
        @theStartDate=Date.today
        flash[:notice] = "Booking only available for up to 6 weeks from now. Sorry"
    end

  params[:mode]=="v" ? @mode="v" : @mode="h"

     params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

    

    

 

    
     if (@error_code==0)
        dbh=connect_array[0]

        @doctors= get_users_ajax


        # temp
        #@doctors=[["Josh Kingston",91,91],["Jimmy Chiu",8,8],["Mike Davis",96,96]] # for testing only
        #@doctors=[["Josh Kingston",91,91]] # for testing only
        @noCols = 3
    
        @displayCount=3
        @startCode=@theStartDate.month*100 + @theStartDate.day
      #theFinishDate = @theStartDate + @noDays.days
        @appointments=[]

      

        
        @dateCodes=[] #to store the relevant days
        @nextAvailable =[] #to store the next available when none found
        
        firstPass = true # to fill @dateCodes once each pass of days
        @doctorsFreesCount=[] # how many free appointments available
        @doctors.each do |doctor|
           
                    i=0
                    
                    
                   @thisDate=@theStartDate
         
                   @appointments[doctor[1]]=[]
                   freesCount = 0
                   while i < @noDays
                        while @thisDate.saturday? or @thisDate.sunday?
                                @thisDate = @thisDate + 1.day
                        end
                       @thisCode=@thisDate.month*100 + @thisDate.day
                        @dateCodes<< [@thisCode,@thisDate] if firstPass

                        freeAppts = []

                        #apptArraySimple = findFrees(dbh,doctor[2],@thisDate)
                        apptArraySimple = findFreesWeb(connectionId,doctor[1],@thisDate)
              
                        apptArraySimple.each_with_index do |apptTime,j|
                            single=1
                            if j < apptArraySimple.length - 1 
                             
                              single =2 if apptTime[0] + 900.seconds== apptArraySimple[j+1][0]

                            end
                            apptCode = apptTime[0].hour * 100 + apptTime[0].min
                            freeAppts << [apptCode, single,apptTime[1]]
                          
                        end

                          # @appointments[doctor[2]][@thisCode]=findFrees(dbh,doctor[2],@thisDate)

                            @appointments[doctor[1]][@thisCode] = freeAppts
                            freesCount = freesCount + @appointments[doctor[1]][@thisCode].length
                         
                            @thisDate = @thisDate + 1.day

                            i=i+1
                          
                  end
                       @doctorsFreesCount[doctor[1]] = freesCount

                       if freesCount == 0
                        # there are no availabla appitmtnets in those days
                        #when is the next?
                          
                        #@nextAvailable[doctor[2]]=getThirdAvailable(dbh,doctor[2],@theStartDate,1,Date.today + 6.weeks)[0]
                        @nextAvailable[doctor[1]]=getNextWeb(connectionId,doctor[1],@theStartDate,Date.today + 8.weeks)
                       end

              
                       firstPass = false


             end

          dbh.disconnect
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
     

     end
     
    #end # temp bypass
   
      closeConnectionId(connectionId)

      #render partial: "show_appt"
  end



  def show
  end

  def downloadcal
      

        @theDate = params[:date].to_date
        @theTime = params[:time].to_s
        @location = "61 Main St, Alstonville NSW Australia"
        @summary = "GP Appointment"
        if params[:summary]
          @summary = params[:summary]
        end


        start_at = DateTime.new(@theDate.year,@theDate.month,@theDate.day,@theTime[0...-2].to_i,@theTime.last(2).to_i)




        # start_at  = DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec, t.zone)
        if params[:duration] == 30
          finish_at = start_at + 30.minutes
        else
          finish_at = start_at + 15.minutes
        end

        cal = Icalendar::Calendar.new
        filename = "alstonville_clinic"

        if params[:format] == 'vcs'
          cal.prodid = '-//Microsoft Corporation//Outlook MIMEDIR//EN'
          cal.version = '1.0'
          filename += '.vcs'
        else # ical
          cal.prodid = '-//Acme Widgets, Inc.//NONSGML ExportToCalendar//EN'
          cal.version = '2.0'
          filename += '.ics'
        end

        cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(start_at)
          e.dtend       = Icalendar::Values::DateTime.new(finish_at)
          e.summary     = @summary
          e.description = params[:description]
          e.location    = @location
        end

        send_data cal.to_ical, type: 'text/calendar', disposition: 'attachment', filename: filename

  end



    def getApptId(dbh,doctor,theDateTime)
      # because of the funny way Genie handles StartTime have to find all appointments and then check their time
        sql =  "SELECT Id, StartTime from Appt WHERE StartDate = '" + theDateTime.to_date.to_s(:db) + "' AND ProviderID = " + doctor.to_s
        puts sql
        sth = dbh.run(sql)
        appt_id=0
        sth.fetch do |row|
            t=row[1]
            if t.hour == theDateTime.hour and t.min == theDateTime.min
                  appt_id=row[0]
            end
        end
        sth.drop
        return appt_id
          

  end

   def confirm


  	 @username = Pref.aladdinuser
  	 @password = Pref.decrypt_password(Pref.aladdinpassword)


  	 connect_array=connect(@username,@password)
     @error_code=connect_array[1]

     if (@error_code==0)
    	  dbh=connect_array[0]
    	  # see if that patient exists
    	  @mobile=params[:mobile]
    	  @surname=params[:Surname]
    	  @firstname=params[:FirstName]

    	  @theDate = params[:date].to_date
        @theTime = params[:time].to_s
       # @theTime = @theTime[0...-2] + ":" + @theTime.last(2)
       #
        @appt_id = params[:appt_id]
        @doctor_id = params[:doctor_id]
       
        params[:apptduration] == "single" ? @duration = 15 : @duration = 30


        @theDateTime = DateTime.new(@theDate.year,@theDate.month,@theDate.day,@theTime[0...-2].to_i,@theTime.last(2).to_i)

        # APPT FOR Doctor @doctor_id by 

    	  sql = "SELECT Surname, FirstName, DOB, MobilePhone, Id, AH_Id_Fk  FROM Patient WHERE Surname = '" + @surname + "' AND (FirstName = '" + @firstname + "' OR KnownAs = '"+ @firstname + "')"   
         puts sql
          sth = dbh.run(sql)
          @patient = sth.fetch_first
          sth.drop


          @patient_match = 0

          if @patient
            @patient_match =1 
          	saved_mobile = @patient[3].gsub(/\s+/, '')
          	#flash[:alert] = @patient[3]
             
             # Does the mobiile number match?
            input_mobile = @mobile.gsub(/\s+/, '')

            if input_mobile == saved_mobile
                @patient_match =2
            else
              # perhaps the mobile matches the mobile of account holder
                  sql = "SELECT Surname, FirstName, DOB, MobilePhone FROM Patient WHERE Id = " + @patient[5].to_s
                  puts sql
                  sth = dbh.run(sql)
                  @ah = sth.fetch_first
                  sth.drop
                  saved_ah_mobile = @ah[3].gsub(/\s+/, '')
                  
                  if input_mobile ==  saved_ah_mobile
                    @patient_match = 2
                  end



                
            end

          end 

           # APPT FOR Doctor @doctor_id for Patient ID @patient[5] whose surname is @patient[0] and first name is @patient[1]
          # @theDate = params[:date].to_date
          # @theTime = params[:time].to_s
          # @theDateTime
          # @duration
          errorCount=0
          if @patient_match == 2
              debugger
              if @appt_id == "0" 
                  @errorId = saveApptTime(@patient[0],@patient[1],@patient[2],@doctor_id,@theDateTime,@duration)
                  ApptLog.info "1 saveApptTime " + @doctor_id + " " + @theDateTime.to_s + " - " + @errorId if @errorId != "0"
                  errorCount=errorCount+1 if @errorId != "0"

                  
              else
                  # this occurs when an appt is type online
                  # the problem is that there is no duration so can't make a double.
                 
                  @errorId = saveApptSlot(@patient[0],@patient[1],@patient[2],@appt_id)
                 ApptLog.info "1 saveApptSlot " + @appt_id + " - " + @errorId if @errorId != "0"
                 errorCount=errorCount+1 if @errorId != "0"

                  if @duration == 30
                    # what is the next apptid?
                    theDateTime2=@theDateTime + 15.minutes
                    @appt_id2=getApptId(dbh,@doctor_id,theDateTime2)

                    if @appt_id2 == 0 
                          @errorId = saveApptTime(@patient[0],@patient[1],@patient[2],@doctor_id,theDateTime2,15)
                          ApptLog.info "2 saveApptTime " + @doctor_id + " " + theDateTime2.to_s + " - " + @errorId if @errorId != "0"
                          errorCount=errorCount+1 if @errorId != "0"
                  
                    else
                     # this occurs when an appt is type online

                          @errorId = saveApptSlot(@patient[0],@patient[1],@patient[2],@appt_id2)
                          ApptLog.info "2 saveApptSlot " + @appt_id2 + " - " + @errorId if @errorId != "0"
                          errorCount=errorCount+1 if @errorId != "0"

                    end
                  
                  end
              end

          else
          	@flash[:alert] =  "No patient"
          end




          
        

    	 
    	 dbh.disconnect        
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]

  	 end

 
     if @patient_match == 2 and errorCount == 0 
        ApptLog.info params['appttime'] + ", duration " + @duration.to_s + " mins for " + @patient[0] + "," + @patient[1]
    		render :success
 	  else
        ApptLog.error params['appttime'] + ", duration " + @duration.to_s + " mins for " + @patient[0] + "," + @patient[1]
    		render :failure
  	end
     


  end

  def default

  	 
  	 @username = Pref.aladdinuser
  	 @password = Pref.decrypt_password(Pref.aladdinpassword)


  	 connect_array=connect(@username,@password)
     @error_code=connect_array[1]
     if (@error_code==0)
    	  dbh=connect_array[0]

    	 
    	 dbh.disconnect        
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]

  	 end


  end



  def saveApptSlot(surname, firstname, dob, appt,reason="")
      @response= SOAPcall(:ws_pr_make_appt,{
           "s44D_vT_Sender" =>  Pref.websender, 
           "s44D_vT_Password" => Pref.decrypt_password(Pref.webpassword),
          "s44D_vL_ID" => appt,
          "s44D_vT_FirstName" => firstname,
          "s44D_vT_Surname" => surname,
          "s44D_vT_DOB" => dob,
          "s44D_vT_Notes" => reason
      })
      
      return @response.body[:ws_pr_make_appt_response][:s44_d_v_l_error]


  end
  def saveApptTime(surname, firstname, dob, doctor,theDateTime,duration,reason="")
      @response= SOAPcall(:ws_pr_make_appt_by_time,{
           "s44D_vT_Sender" =>  Pref.websender, 
           "s44D_vT_Password" => Pref.decrypt_password(Pref.webpassword),
           "s44D_vT_StartDate" => theDateTime,
           "s44D_vL_Duration" => duration,
           "s44D_vL_Provider" => doctor,
           "s44D_vT_Type" => "",
          "s44D_vT_FirstName" => firstname,
          "s44D_vT_Surname" => surname,
          "s44D_vT_DOB" => dob,
          "s44D_vT_Notes" => reason
      })
      debugger
      return @response.body[:ws_pr_make_appt_by_time_response][:s44_d_v_l_error]


  end

  def findFreesWeb(connectionId,doctor,theDate)
  		# this is using the genie premium web service approach
  		# is it quicker?

  		# find designated online slots

      @response= SOAPcall(:ws_pr_get_free_appts,{
          "s44D_vConnectionID" =>  connectionId,
          "s44D_vT_StartDate" => theDate, 
          "s44D_vT_EndDate" => theDate,
          "s44D_vL_Provider" => doctor
      })







	  errorId = @response.body[:ws_pr_get_free_appts_response][:s44_d_v_l_error]
	  puts "errorId = " + errorId
	  appts=[]

	  if errorId == "0"
	  		# there are some appointments

	  		xml_appts = Base64.decode64(@response.body[:ws_pr_get_free_appts_response][:s44_d_v_x_output])
	  		apptsHash = Hash.from_xml(xml_appts)

   
            apptsHash["appts"]["appt"].each do |appointment|
                 puts appointment
              begin
                appts << [appointment["dateTime"].to_datetime, appointment["id"]]
              rescue
                appts << [apptsHash["appts"]["appt"]["dateTime"].to_datetime,apptsHash["appts"]["appt"]["id"]]
                break
              end
            end

          


          


	  		
	   end


    # also need to get vacants of prefs allow
    if Pref.vacants


      @response= SOAPcall(:ws_pr_get_vacant_appts,{
          "s44D_vConnectionID" =>  connectionId, 
          "s44D_vT_StartDate" => theDate, 
          "s44D_vT_EndDate" => theDate,
          "s44D_vL_Provider" => doctor
        })



        errorId = @response.body[:ws_pr_get_vacant_appts_response][:s44_d_v_l_error]
        puts "errorId = " + errorId
        if errorId == '-15760'
            puts "get_vacants - provider = " + doctor.to_s
        end
       
        if errorId == "0"
            # there are some appointments

            xml_appts = Base64.decode64(@response.body[:ws_pr_get_vacant_appts_response][:s44_d_v_x_output])
            apptsHash = Hash.from_xml(xml_appts)
            apptsHash["appts"]["appt"].each do |appointment|
               begin
                appts << [appointment["dateTime"].to_datetime, 0]
              rescue
                appts << [apptsHash["appts"]["appt"]["dateTime"].to_datetime,0]
                break
              end

            end

            # now need to sort array appts by time
            appts = appts.sort {|a,b| a[0] <=> b[0]}


        
        end


    end

	  return appts






  end


  def getNextWeb(connectionId, doctor, startDate=Date.today, finishDate = Date.today + 6.weeks)
      theDate=startDate
      found=false

           # are there any already vacant appointments ?
      @response= SOAPcall(:ws_pr_get_free_appts,{
              "s44D_vConnectionID" =>  connectionId,
              "s44D_vT_StartDate" => theDate, 
              "s44D_vT_EndDate" => finishDate,
              "s44D_vL_Provider" => doctor
      })

      errorId = @response.body[:ws_pr_get_free_appts_response][:s44_d_v_l_error]
      puts "errorId = " + errorId
       if errorId == '-15760'
            puts "get next web - provider = " + doctor.to_s
        end
      nextAppt=""
      if errorId == "0"
        # there are some appointments

        xml_appts = Base64.decode64(@response.body[:ws_pr_get_free_appts_response][:s44_d_v_x_output])
        apptsHash = Hash.from_xml(xml_appts)

        apptsHash["appts"]["appt"].each do |appointment|
                 puts appointment
              begin
                thisAppt = appointment["dateTime"].to_datetime
                unless thisAppt.saturday? or thisAppt.sunday?

                  nextAppt = thisAppt
                  break
                end
              rescue
                thisAppt = apptsHash["appts"]["appt"]["dateTime"].to_datetime
                unless thisAppt.saturday? or thisAppt.sunday?
                    nextAppt = thisAppt
                end
                break
              end
        end

      end


            # are there any already slotted appointments today ?
      if Pref.vacants
        @response= SOAPcall(:ws_pr_get_vacant_appts,{
                  "s44D_vConnectionID" =>  connectionId,
                  "s44D_vT_StartDate" => theDate, 
                  "s44D_vT_EndDate" => finishDate,
                  "s44D_vL_Provider" => doctor
          })
        errorId = @response.body[:ws_pr_get_vacant_appts_response][:s44_d_v_l_error]
        puts "errorId = " + errorId
        if errorId == '-15760'
            puts "provider = " + doctor.to_s
        end
         thisNextAppt =""
        if errorId == "0"
          # there are some appointments
         
          xml_appts = Base64.decode64(@response.body[:ws_pr_get_vacant_appts_response][:s44_d_v_x_output])
          apptsHash = Hash.from_xml(xml_appts)
         apptsHash["appts"]["appt"].each do |appointment|
                 puts appointment
              begin
                thisAppt = appointment["dateTime"].to_datetime
                unless thisAppt.saturday? or thisAppt.sunday?

                  thisNextAppt = thisAppt
                  break
                end
              rescue
                thisAppt = apptsHash["appts"]["appt"]["dateTime"].to_datetime
                unless thisAppt.saturday? or thisAppt.sunday?
                    thisNextAppt = thisAppt
                end
                break
              end
          end

          if nextAppt == "" or thisNextAppt < nextAppt
              nextAppt = thisNextAppt
          end
        end
      end

      return nextAppt
  end

  def getConnectionId(sender,password)
  	  ip = get_ip
      client = Savon.client(wsdl: 'http://'+ip+':19080/4dwsdl')
      @calls = client.operations
	  @response = client.call(
        :s44_d_new_connection, 
        message: { 
          "s44D_vT_Sender" =>  sender, "s44D_vT_Password" => password
        })
	  if @response.body[:s44_d_new_connection_response][:s44_d_v_l_error] == "0"
	  		connectionId = @response.body[:s44_d_new_connection_response][:s44_d_v_connection_id]

	  else
	  		connectionId = 0

	  end
	  puts "Open ConnectionId " + connectionId.to_s
	  return connectionId

  end

  def closeConnectionId(connectionId)

  	  ip = get_ip
      client = Savon.client(wsdl: 'http://'+ip+':19080/4dwsdl')
      @calls = client.operations
	  @response = client.call(
        :s44_d_close_connection, 
        message: { 
          "s44D_vConnectionID" =>  connectionId.to_s
        })
	  puts "Close ConnectionId " + connectionId.to_s

  end

  def SOAPcall(theCall,messages)
        ip = get_ip
        client = Savon.client(wsdl: 'http://'+ip+':19080/4dwsdl')
        @calls = client.operations
        response = client.call(theCall, message: messages)
        return response
  end


  def findFreesNew(doctor,theDate)
          @frees = Slot.where(available: true).order(:appointment).all
          return @frees


  end







   def findFrees(dbh,doctor,theDate)
   		leave = false
   			# is the doctor on annual leave
   		 sql =  "SELECT Count(Id) from Appt WHERE StartDate = '" + theDate.to_s(:db) + "' AND ProviderID = " + doctor.to_s + " AND Reason = 'ANNUAL LEAVE'"
          puts sql
          sth= dbh.run(sql)
          row= sth.fetch_first

          if row and row[0].to_i > 0
          	leave = true

          end
          sth.drop

          # is the day blocked
          sql =  "SELECT Count(Id) from ApptBlock WHERE StartDate = '" + theDate.to_s(:db) + "' and ProviderID = " + doctor.to_s
           puts sql
          sth= dbh.run(sql)
          row= sth.fetch_first
          if row and row[0].to_i > 0 
          	leave = true

          end
          sth.drop


          # if leave is > 0 then doctor is not here so can stop checking
                                       
          appointments=[]

          unless leave
         

          			# find all the appotintments that are booked or have a reason except those marked 'Online' and 

		          	sql =  "SELECT StartDate, StartTime, ApptDuration, Id, Reason from Appt WHERE StartDate = '" + theDate.to_s(:db) + "' AND ProviderID = " + doctor.to_s + "   AND (Reason <> 'Online' or (Reason = 'Online' and Pt_Id_Fk <> 0)) and (Reason <> 'consult' or (Reason = 'consult' and Pt_Id_Fk <> 0)) AND (Reason <> 'ROUTINE AT ANNEXE' or (Reason = 'ROUTINE AT ANNEXE' and Pt_Id_Fk <> 0))  ORDER BY StartTime"
		           
		           puts sql
		           sth= dbh.run(sql)
		           appts=[]


		           sth.fetch do |row|
				              # genie does a funny thing where the StartTime ddmmyy are wrong, only the time counts !
				              # appt duration is in secs and 900 secs = 15 minutes

				             t=row[1]

				             
				             t=t.change(:year => theDate.year, :month => theDate.month,:day => theDate.day)
				             unless t < Time.now
				           
									appts<<[t, row[2]]
						
				          	end
		      		end
		      		sth.drop
		          
		          freeAppt=0
		          
		          # must be at least 4 appointments if working - lunch, Mrs B etc
		          if appts.count>4
		                    nextAppt = appts[0][0]
		                    # freeAppt=nextAppt
		                    appts.each do |appt|
		                        # is the next appt blank
		                            
		                            t = appt[0]
		                            
		                            # is this expected appt
		                            
		                            while t > nextAppt
		                            		 # so this slot is available
		                                     freeAppt = freeAppt + 1
		                                     # apptCode = nextAppt.hour * 100 + nextAppt.min
		                                     appointments << nextAppt
		                                     nextAppt = nextAppt + 900.seconds

		                            end
		                            
		                            nextAppt = t + appt[1].seconds

		                    end


		        
		          			while nextAppt.hour < 16  or (nextAppt.hour == 16 and nextAppt.min < 45)
		                  
				                  freeAppt = freeAppt+1
				                  # apptCode = nextAppt.hour * 100 + nextAppt.min
				                  appointments << nextAppt
				                  #puts freeAppt
				                  nextAppt = nextAppt + 900.seconds
				                  break if freeAppt>100
		         			 end
		         	end # if appts.count > 4

         end  # unless leave 
         
         return appointments


  	

		end



  def saveappointment(appt_id,patient,notes = "From Aladdin")
      ip = get_ip
      client = Savon.client(wsdl: 'http://'+ip+':19080/4dwsdl')
      @calls = client.operations


        @response = client.call(
        :WS_MakeAppt, 
        message: { 
          "s44D_vL_ID" =>  appt_id, "s44D_vT_Name" => patient, "s44D_vT_Notes" => "Testing - please delete"
        })
 
 end

# new stuff all below here

def updateSlots
     @username = Pref.aladdinuser
     @password = Pref.decrypt_password(Pref.aladdinpassword)
     connect_array=connect(@username,@password)
     @error_code=connect_array[1]


     startdate=Date.today
     days=56
     if days==0
            
            finishdate = Date.today + 1.years
     else
            finishdate = startdate + days.days
     end

     if (@error_code==0)
        dbh=connect_array[0]

        @deletedAppts=[]
        @doubledAppts=[]
        #@deletedApptsOld = checkCancellations(dbh,startdate)


          #whats been updated
         
                @deletedApptsArray = checkCancellations(dbh,startdate)
                @deletedAppts=@deletedApptsArray[0]
                @doubledAppts=@deletedApptsArray[1]
            
                @modTime = File.mtime(::Rails.root.join('public','slots.txt'))

                a=Pref.where(name: :lastAllAvailable).first
                @allavailabledate = a.value.to_date

                # need to make all available from last allavailabletime to today + days.days
                shouldBe = Date.today + days.days
              
                if shouldBe > @allavailabledate
                    daysToAdd = (shouldBe - @allavailabledate).to_i
                    make_all_available(shouldBe,daysToAdd)
                end
               
                
                @modTime=@modTime.utc

                @modTimeStr = @modTime.strftime("%Y%m%d%H%M%S")
                #@modTimeStr ="20210108092035"
                @updatedAppts =  loadNewBookings(dbh,startdate,@modTimeStr)
                @updatedBlocks = loadNewBlocks(dbh,startdate,@modTime)

                
          
            
          

        # @doctors= get_users_ajax

        FileUtils.touch(::Rails.root.join('public','slots.txt'))
        dbh.disconnect



        #@frees = findFreesNew(doctor,theDate)
        
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
     

     end
     
    #end # temp bypass
   
    


end



  def slots
    # this is for testing    # get appointments
     @username = Pref.aladdinuser
     @password = Pref.decrypt_password(Pref.aladdinpassword)
     @websender = Pref.websender
     @webpassword = Pref.decrypt_password(Pref.webpassword)

     connectionId = getConnectionId(@websender,@webpassword)

     params[:action] = ""




     



     connect_array=connect(@username,@password)
     @error_code=connect_array[1]

     
     @preventPast=true
 
     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
     elsif params[:day] != nil and params[:month] != nil and params[:year] != nil
        @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
     else
        @theStartDate=Date.today
     end
     if @theStartDate > Date.today + 6.weeks
        @theStartDate=Date.today
        flash[:notice] = "Booking only available for up to 6 weeks from now. Sorry"
     end

    params[:mode]=="v" ? @mode="v" : @mode="h"

    params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3



    

    
     startdate=Date.today
     #How many days ahead to make slots available
     days = 100

     #This is now deprecated as there is no finish date

     #if days==0
            
     #       finishdate = Date.today + 1.years
     # else
      #      finishdate = startdate + days.days
     # end

    
     if (@error_code==0)
        dbh=connect_array[0]

        
        @missedAppts=[]

        
        #@deletedApptsOld = checkCancellations(dbh,startdate)
         if params[:init]           
            Slot.delete_all
            make_all_available(startdate,days)
            loadNewBlocks(dbh,startdate)
            loadNewBookings(dbh,startdate)
            
             FileUtils.touch(::Rails.root.join('public','slots.txt'))
          else

          #whats been updated
            if params[:update]
                #@deletedAppts = checkCancellations(dbh,startdate)

            
                @modTime = File.mtime(::Rails.root.join('public','slots.txt'))

                a=Pref.where(name: :lastAllAvailable).first
                @allavailabledate = a.value.to_date

                # need to make all available from last allavailabletime to today + days.days
                shouldBe = Date.today + days.days
              
                if shouldBe > @allavailabledate
                    daysToAdd = (shouldBe - @allavailabledate).to_i
                    make_all_available(shouldBe,daysToAdd)
                end
               
                
                @modTime=@modTime.utc

                @modTimeStr = @modTime.strftime("%Y%m%d%H%M%S")
                modDate = @modTime.strftime("%Y-%m-%d")

                #@modTimeStr ="20210108092035"
                @updatedAppts =  loadNewBookings(dbh,startdate,@modTimeStr)
                @updatedBlocks = loadNewBlocks(dbh,startdate,@modTime)
                @deleteds = checkDeleted(dbh,startdate,modDate)
                @deletedAppts =  @deleteds[0]
                @deletedSlots =  @deleteds[1]

               # @missedAppts = checkMissed(dbh,startdate)
              FileUtils.touch(::Rails.root.join('public','slots.txt'))

                
            end
            
          end

        # @doctors= get_users_ajax

        
        dbh.disconnect



        #@frees = findFreesNew(doctor,theDate)
        
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
     

     end
     
    #end # temp bypass
   
      closeConnectionId(connectionId)

end



 def showslots
    # this is for testing    # get appointments
     @username = Pref.aladdinuser
     @password = Pref.decrypt_password(Pref.aladdinpassword)
     @websender = Pref.websender
     @webpassword = Pref.decrypt_password(Pref.webpassword)

     connectionId = getConnectionId(@websender,@webpassword)

     params[:action] = ""




     



     connect_array=connect(@username,@password)
     @error_code=connect_array[1]

     
     @preventPast=true
 
     if params[:date] 
        @theStartDate = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
     elsif params[:day] != nil and params[:month] != nil and params[:year] != nil
        @theStartDate = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
     else
        @theStartDate=Date.today
     end
     if @theStartDate > Date.today + 6.weeks
        @theStartDate=Date.today
        flash[:notice] = "Booking only available for up to 6 weeks from now. Sorry"
     end

    params[:mode]=="v" ? @mode="v" : @mode="h"

    params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3



    

    
     startdate=Date.today

     #This is now deprecated as there is no finish date
     #days=100
     #if days==0
            
     #       finishdate = Date.today + 1.years
     # else
      #      finishdate = startdate + days.days
     # end

    
     if (@error_code==0)
        dbh=connect_array[0]

        #@deletedAppts= checkDeleted(dbh,startdate)
       #  @missedAppts=[]

        
        #@deletedApptsOld = checkCancellations(dbh,startdate)
         if params[:init]           
            Slot.delete_all
            make_all_available(startdate,days)
            loadNewBlocks(dbh,startdate)
            loadNewBookings(dbh,startdate)
            
             FileUtils.touch(::Rails.root.join('public','slots.txt'))
          else

          #whats been updated
            if params[:update]
                #@deletedAppts = checkCancellations(dbh,startdate)
               
            
                @modTime = File.mtime(::Rails.root.join('public','slots.txt'))

                a=Pref.where(name: :lastAllAvailable).first
                @allavailabledate = a.value.to_date

                # need to make all available from last allavailabletime to today + days.days
                shouldBe = Date.today + days.days
              
                if shouldBe > @allavailabledate
                    daysToAdd = (shouldBe - @allavailabledate).to_i
                    make_all_available(shouldBe,daysToAdd)
                end
               
                
                @modTime=@modTime.utc

                @modTimeStr = @modTime.strftime("%Y%m%d%H%M%S")
                #@modTimeStr ="20210108092035"
                @updatedAppts =  loadNewBookings(dbh,startdate,@modTimeStr)
                @updatedBlocks = loadNewBlocks(dbh,startdate,@modTime)

               # @missedAppts = checkMissed(dbh,startdate)
              FileUtils.touch(::Rails.root.join('public','slots.txt'))

                
            end
            
          end

        # @doctors= get_users_ajax

        
        dbh.disconnect



        #@frees = findFreesNew(doctor,theDate)
        
          
     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
     

     end
     
    #end # temp bypass
   
      closeConnectionId(connectionId)

end

def checkDeleted(dbh,startdate,modDate=0)
        # this is the real deal sp needs work!
  #  SELECT APT_Id_Fk,PT_Id_Fk,ProviderId,ApptDate,ApptTime,DeleteDate,RoomID,Name,Note,DeleteTime,DeletedBy,ProcessName,Reason,Parent_APT_Id_Fk,Multiple,SMSReply,Id,Duration from DeletedAppt where PT_Id_Fk = 4998"
      
        #Bugger. DeletedAppt uses DeleteDate and DeleteTime and they are different.
        # DeleteDate would be OK.

         @provider_ids = Provider.pluck(:genie_id)
        providerStr = @provider_ids.join( " or ProviderId = ")
        providerStr = "ProviderId = " + providerStr
        
      
      if modDate == 0
            sql =  "SELECT APT_Id_Fk, ProviderId, ApptDate, ApptTime, Name , DeleteDate, DeleteTime from DeletedAppt WHERE ApptDate >= '" + startdate.to_s(:db) + "' and ( " + providerStr + ") and PT_Id_Fk > 0"  
      else
            sql =  "SELECT APT_Id_Fk, ProviderId, ApptDate, ApptTime, Name , DeleteDate, DeleteTime from DeletedAppt WHERE DeleteDate >= '"+ modDate + "' and ( " + providerStr + ") and PT_Id_Fk > 0"  

       end



        puts sql
        sth= dbh.run(sql)

        deletedAppts =[]
        deletedSlots=[]
        sth.fetch do |row|
                deletedAppts << row
                appt_id = row[0]
                if slot=Slot.where(appt_id: appt_id).first
                     deletedSlots << slot
                      # if there is one or more other appointments at that time, delete rather than replace slot
                      slotcount=Slot.where(appointment: slot.appointment, doctor_id: slot.doctor_id).count
                      if slotcount > 1
                        slot.destroy
                      else              
                        slot.patient_id=nil
                        slot.available=available?(slot.apptype,0)
                        slot.patient_name = nil
                        slot.appt_id = nil
                        slot.save
                      end
                end
        end
       
        sth.drop
        return [deletedAppts,deletedSlots]

        
end

def checkCancellationsOld(dbh,startdate,finishdate=0)
          thisdate=startdate
          if finishdate == 0
              finishdate=startdate
          end


        #what is the first appt for this period()
        #lowestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id").first
        #highestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id DESC").first
        #debugger
        sql =  "SELECT Id from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and StartDate <= '" + finishdate.to_s(:db) + "' and PT_Id_Fk > 0"
        puts sql
        sth= dbh.run(sql)
           

       appts=[]
       keepgoing=true
       sth.fetch do |row|
          appts << row[0]
      end

       slots = Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', startdate.beginning_of_day, finishdate.end_of_day).all
       deletedSlots=[]
       #any slots that don;t have a value in appts have been deleted and should be clears
       slots.each do |slot|
              unless appts.include?(slot.appt_id)
                  
                  #@slot=Slot.find(slot.id)
                  deletedSlots << slot
                  #@slot.patient_id=0
                  #@slot.available=true
                  #@slot.save
              end
       end
       sth.drop
       return deletedSlots
      
          


      

end




def checkMissed(dbh,startdate)
          thisdate=startdate
         


        #what is the first appt for this period()
        #lowestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id").first
        #highestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id DESC").first
        #debugger


        @provider_ids = Provider.where(online: true).pluck(:genie_id)
        providerStr = @provider_ids.join( " or ProviderID = ")
        providerStr = "ProviderID = " + providerStr

        sql =  "SELECT Id, ProviderID, Name, StartTime,StartDate,Reason,ApptDuration, PT_Id_Fk from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and ( " + providerStr + ")and PT_Id_Fk > 0"
        puts sql
        sth= dbh.run(sql)
           

       appts=[]
       apptInfo=[]
       keepgoing=false
       sth.fetch do |row|
          appts << row[0]
          apptInfo[row[0]]=row
      end

       slots = Slot.where('patient_id > 0 and appointment > ?', startdate.beginning_of_day).uniq.pluck(:appt_id)
     
       missedApptsArray=appts-slots
       missedAppts=[]
      
       #any slots that don;t have a value in appts have been deleted and should be clears
       missedApptsArray.each do |appt_id|
                  #appt_id is not in slots
             
                  # deletedSlots << @slot=Slot.find(slot.id)
                 
                      missedAppts << apptInfo[appt_id]  
                      t=apptInfo[appt_id][3]
                      apptDate=apptInfo[appt_id][4]

                      
                      t=t.change(:year => apptDate.year, :month => apptDate.month,:day => apptDate.day)

                         unless t < Time.now
                              # is this a double booking or an updated booking

                                  numberSlots = apptInfo[appt_id][6]/900
                                  loops = 1 
                                  while loops <= numberSlots
                                      @slot=Slot.where(appt_id: appt_id,appointment: t).first_or_initialize
                              
                                      if apptInfo[appt_id][2].encoding.name == "ASCII-8BIT"
                                            apptInfo[appt_id][2].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                            
                                      end
                                      @slot.patient_id = apptInfo[appt_id][7]
                                      @slot.doctor_id = apptInfo[appt_id][1]
                                      @slot.patient_name =  apptInfo[appt_id][2].split("-")[0]
                                      if apptInfo[appt_id][5].encoding.name == "ASCII-8BIT"
                                        apptInfo[appt_id][5].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                        
                                      end
                                    
                                      @slot.apptype =  apptInfo[appt_id][5]
                                      @slot.available = available?(@slot.patient_id,@slot.apptype)
                                      begin
                                        @slot.save
                                      rescue
                                        if keepgoing
                                          debugger
                                        end
                                      end
                                      loops =loops +1
                                      t = t + 15.minutes
                                  end
                             
                              
                        end

                      #slot.patient_id=0
                      #slot.available=available?(slot.apptype,0)
                      #slot.patient_name = nil
                      #slot.save
                      
                   
        end

        #         @slot=Slot.find(slot.id)
        #          @slot.patient_id=0
        #          @slot.available=true
        #          @slot.save
             
       sth.drop
       return missedAppts
      
          


      

end

def checkCancellations2(dbh,startdate)
          thisdate=startdate
         
          # there is a table called DeletedAppt which will make this easier!!!!!

        #what is the first appt for this period()
        #lowestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id").first
        #highestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id DESC").first
        #debugger
        @provider_ids = Provider.pluck(:genie_id)
        providerStr = @provider_ids.join( " or ProviderID = ")
        providerStr = "ProviderID = " + providerStr

        sql =  "SELECT Id from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and ( " + providerStr + ") and PT_Id_Fk > 0"
        puts sql
        sth= dbh.run(sql)
           

       appts=[]
       keepgoing=false
       sth.fetch do |row|
          appts << row[0]
      end

       slots = Slot.where('patient_id > 0 and appointment >= ?', startdate.beginning_of_day).uniq.pluck(:appt_id)
       
       deletedSlotsArray=slots-appts
       deletedSlots=[]


     
       #any slots that don;t have a value in appts have been deleted and should be clears
       deletedSlotsArray.each do |appt_id|

             
                  # deletedSlots << @slot=Slot.find(slot.id)
                  @slots=Slot.where(appt_id: appt_id).all
                  @slots.each do |slot|    
                      deletedSlots << slot
                      # if there is one or more other appointments at that time, delete rather than reaplce slot
                      slotcount=Slot.where(appointment: slot.appointment, doctor_id: slot.doctor_id).count
                      if slotcount > 1
                        slot.destroy
                      else              
                        slot.patient_id=nil
                        slot.available=available?(slot.apptype,0)
                        slot.patient_name = nil
                        slot.appt_id = nil
                        slot.save
                      end
                      
                   
                  end

        #         @slot=Slot.find(slot.id)
        #          @slot.patient_id=0
        #          @slot.available=true
        #          @slot.save
             
       end
       sth.drop
       return deletedSlots
      
          


      

end

def checkCancellations(dbh,startdate)
          thisdate=startdate
         
          # there is a table called DeletedAppt which will make this easier!!!!!

        #what is the first appt for this period()
        #lowestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id").first
        #highestSlot=Slot.where('patient_id > 0 and appointment BETWEEN ? AND ?', thisdate.beginning_of_day, finishdate.end_of_day).order("appt_id DESC").first
        #debugger
        @provider_ids = Provider.pluck(:genie_id)
        providerStr = @provider_ids.join( " or ProviderID = ")
        providerStr = "ProviderID = " + providerStr

        sql =  "SELECT APT_Id_Fk, ProviderID, ApptDate, ApptTime from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and ( " + providerStr + ") and PT_Id_Fk > 0"
        puts sql
        sth= dbh.run(sql)
        debugger

        deletedSlots = []
        sth.fetch do |row|
          # need to delete the slot where appt_id = row[0]
          if @slot=Slot.where(appt_id: appt_id).first
                     deletedSlots << slot
                      # if there is one or more other appointments at that time, delete rather than reaplce slot
                      slotcount=Slot.where(appointment: slot.appointment, doctor_id: slot.doctor_id).count
                      if slotcount > 1
                        slot.destroy
                      else              
                        slot.patient_id=nil
                        slot.available=available?(slot.apptype,0)
                        slot.patient_name = nil
                        slot.appt_id = nil
                        slot.save
                      end
          end
      end

     



    
       sth.drop
       return deletedSlots
      
          


      

end





def loadNewBookings(dbh,startdate,modtime=0)
      keepgoing=false
      # FileUtils.touch(::Rails.root.join('public','slots.txt'))
      if modtime == 0
            sql =  "SELECT StartDate, StartTime, ApptDuration, Reason, ProviderID, PT_Id_Fk, Name, Id from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and (" + Provider.providerStr + ") ORDER BY StartTime"
      else
            sql =  "SELECT StartDate, StartTime, ApptDuration, Reason, ProviderID, PT_Id_Fk, Name, Id from Appt WHERE LastUpdated > '"+ modtime +"'  and (" + Provider.providerStr + ") "
       
      end       
               puts sql
              
               sth= dbh.run(sql)
               appts=[]

               @slots=[]
               keepgoing=false
               sth.fetch do |row|
                     
                      @slots << row  unless modtime==0
                      # genie does a funny thing where the StartTime ddmmyy are wrong, only the time counts !
                      # appt duration is in secs and 900 secs = 15 minutes

                      # appointmnet may not be for a doctor eg express clinic
                      if Provider.where(genie_id: row[4]).first
                         t=row[1]
                         apptDate=row[0]

                         puts t.to_s, row[6]
                         t=t.change(:year => apptDate.year, :month => apptDate.month,:day => apptDate.day)

                         unless t < Time.now
                              # is this a double booking or an updated booking

                                  numberSlots = row[2]/900
                                  loops = 1 
                                  while loops <= numberSlots
                                      @slot=Slot.where(appt_id: row[7],appointment: t).first
                                     
                                      if @slot == nil
                                        # it is a new appointment. is there an avaialble appt to replace or is it a doube booked appointment
                                        @slot=Slot.where(appointment: t, doctor_id: row[4]).first
                                        if @slot == nil or @slot.available == false
                                            # iNeed to create a new slot, otherwise overwrite the available slot
                                              @slot == nil ? apptype = "Consult" : apptype = @slot.apptype
                                              @slot=Slot.new(appointment: t, doctor_id: row[4], apptype: apptype)
                                        end
                                      
                                        @slot.appt_id=row[7]
                                        
                                      end
                              
                                      if row[6].encoding.name == "ASCII-8BIT"
                                            row[6].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                            
                                      end
                                       @slot.doctor_id = row[4]
                                       @slot.patient_id = row[5]
                                      @slot.patient_name =  row[6].split("-")[0]
                                      if row[3].encoding.name == "ASCII-8BIT"
                                        row[3].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                        
                                      end
                                    
                                      @slot.apptype =  row[3]
                                      @slot.available = available?(row[3],row[5])
                                      if keepgoing
                                          debugger
                                        end
                                      begin
                                        @slot.save
                                      rescue
                                        if keepgoing
                                          debugger
                                        end
                                      end
                                      loops =loops +1
                                      t = t + 15.minutes
                                  end
                             
                              
                        end
                    end
              end
              sth.drop
              return @slots
end





def loadBookings(dbh,startdate,finishdate)

     sql =  "SELECT StartDate, StartTime, ApptDuration, Reason, ProviderID, PT_Id_Fk, Name, Id from Appt WHERE StartDate >= '" + startdate.to_s(:db) + "' and StartDate < '" + finishdate.to_s(:db) + "' ORDER BY StartTime"
               
               puts sql
               sth= dbh.run(sql)
               appts=[]

               @slots=[]
               keepgoing=true
               sth.fetch do |row|
                      # genie does a funny thing where the StartTime ddmmyy are wrong, only the time counts !
                      # appt duration is in secs and 900 secs = 15 minutes

                      # appointmnet may not be for a doctor eg express clinic
                      if Provider.where(genie_id: row[4]).first
                         t=row[1]
                         apptDate=row[0]

                         puts t.to_s, row[6]
                         t=t.change(:year => apptDate.year, :month => apptDate.month,:day => apptDate.day)

                         unless t < Time.now
                            numberSlots = row[2]/900
                            loops = 1 
                            while loops <= numberSlots
                                @slot=Slot.where(appointment: t, doctor_id: row[4]).first_or_initialize
                                @slow.block_id = row[7]
                       
                                @slot.patient_id = row[5]
                                if row[6].encoding.name == "ASCII-8BIT"
                                      row[6].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                      
                                end
                                @slot.patient_name =  row[6].split("-")[0]
                                if row[3].encoding.name == "ASCII-8BIT"
                                  row[3].encode!("UTF-8", "ASCII-8BIT", :invalid => :replace, :undef => :replace, :replace => "")
                                  
                                end
                              
                                @slot.apptype =  row[3]
                                @slot.available = available?(row[3],row[5])
                                begin
                                  @slot.save
                                rescue
                                  if keepgoing
                                    debugger
                                  end
                                end
                                loops =loops +1
                                t = t + 15.minutes
                            end
                             
                              
                        end
                    end
              end
              sth.drop

end

def loadNewBlocks(dbh,startDate,modtime=0)
    # the blocks that are rele vant today have a start date <= today and an enddate >= today
      keepgoing = true
      
      startTime = Pref.firstAppt.split(":")
      starthour = startTime[0].to_i
      startminute = startTime[1].to_i
      finishTime = Pref.lastAppt.split(":")
      finishhour = finishTime[0].to_i
      finishminute = finishTime[1].to_i

          if modtime == 0
            sql =  "SELECT StartTime, StartDate, BlockDuration, Reason, ProviderID, EndDate,Id from ApptBlock WHERE (StartDate >= '" + startDate.to_s(:db) + "' or (StartDate < '" + startDate.to_s(:db) + "' and EndDate >= '" + startDate.to_s(:db) + "'))  and (" + Provider.providerStr + ") "
          
          else
            sql =  "SELECT StartTime, StartDate, BlockDuration, Reason, ProviderID, EndDate,Id from ApptBlock WHERE (LastUpdatedDateTime > '" + modtime.to_s(:db) + "' AND (StartDate >= '" + startDate.to_s(:db) + "' or (StartDate < '" + startDate.to_s(:db) + "' and EndDate >= '" + startDate.to_s(:db) + "'))  and (" + Provider.providerStr + ") )"
        

          end
          puts sql
        
          sth= dbh.run(sql)
          @updatedBlocks=[]
          sth.fetch do |row|
              
                  @updatedBlocks<<row unless modtime==0
                  
                  t = row[0]
                  apptDate=row[1]
                  endDate=row[5]
                  if endDate == nil
                    endDate=apptDate
                  end
                

                  thisDate = apptDate
                  if thisDate < startDate
                      thisDate=startDate
                  end
                 
                  while thisDate <= endDate
                    progressedTime=0
                    t = row[0]
                    t=t.change(:year => thisDate.year, :month => thisDate.month,:day => thisDate.day)
                   
                    
                    
                    # Check slot for each appointment
                      while progressedTime <= row[2]
                              if (! t.saturday? and ! t.sunday?) and (t.hour.to_i > starthour or (t.hour.to_i == starthour and t.min.to_i >= startminute)) and (t.hour.to_i < finishhour.to_i or (t.hour.to_i == finishhour and  t.min.to_i <= finishminute))
                                 
                                       @slot=Slot.where(appointment: t, doctor_id: row[4]).first_or_initialize
                                    
                                       
                                    
                                   
                                        @slot.apptype =  row[3]
                                        @slot.available = available?(row[3],0)

                                        @slot.save
                                        puts "saving " + row[3] + " for " + row[4].to_s + " " + t.to_s
                                    

                                    
                              end
                              progressedTime = progressedTime + 900
                              t = t + 900
                      end
                      thisDate = thisDate + 1.days
                    
                  
                  end
              
          end
          sth.drop
          return @updatedBlocks

end

def loadBlocks(dbh,startDate)
    # the blocks that are rele vant today have a start date <= today and an enddate >= today
      keepgoing = false
      
      startTime = Pref.firstAppt.split(":")
      starthour = startTime[0].to_i
      startminute = startTime[1].to_i
      finishTime = Pref.lastAppt.split(":")
      finishhour = finishTime[0].to_i
      finishminute = finishTime[1].to_i


          sql =  "SELECT StartTime, StartDate, BlockDuration, Reason, ProviderID, EndDate,Id from ApptBlock WHERE (StartDate >= '" + startDate.to_s(:db) + "' or (StartDate < '" + startDate.to_s(:db) + "' and EndDate >= '" + startDate.to_s(:db) + "')  and (" + Provider.providerStr + ") )"
          puts sql
          sth= dbh.run(sql)
          sth.fetch do |row|
                  progressedTime=0
                  t = row[0]
                  apptDate=row[1]
                  endDate=row[5]
                  if endDate == nil
                    endDate=startDate
                  end
                

                  thisDate = apptDate
                  if thisDate < startDate
                      thisDate=startDate
                  end
                  
                  while thisDate <= endDate
                   
                    t = row[0]
                    t=t.change(:year => thisDate.year, :month => thisDate.month,:day => thisDate.day)
                    
                    # Check slot for each appointment
                      while progressedTime <= row[2]
                              if (! t.saturday? and ! t.sunday?) and (t.hour.to_i > starthour or (t.hour.to_i == starthour and t.min.to_i >= startminute)) and (t.hour.to_i < finishhour.to_i or (t.hour.to_i == finishhour and  t.min.to_i <= finishminute))
                                 
                                    @slot=Slot.where(appointment: t, doctor_id: row[4]).first_or_initialize
                                    
                                       
                                    
                                   
                                        @slot.apptype =  row[3]
                                        @slot.available = available?(row[3],0)

                                        @slot.save
                                        puts "saving " + row[3] + " " + t.to_s
                                    

                                    
                              end
                              progressedTime = progressedTime + 900
                              t = t + 900
                      end
                      thisDate = thisDate + 1.days
                    
                  
                  end

          end
          sth.drop


end


def make_all_available(startdate,days)
      # won't overide existing appointment
      startTime = Pref.firstAppt.split(":")
      starthour = startTime[0].to_i
      startminute = startTime[1].to_i
      finishTime = Pref.lastAppt.split(":")
      finishhour = finishTime[0].to_i
      finishminute = finishTime[1].to_i
      d=0
      allproviders = Provider.all
      keepgoing = true
      while d < days

            thisAppt = Time.new(startdate.year,startdate.month, startdate.day,starthour,startminute)
            lastAppt = Time.new(startdate.year,startdate.month, startdate.day,finishhour,finishminute)
            unless keepgoing
                debugger
            end
            puts "Last appt is " + lastAppt.to_s
            unless thisAppt.saturday? or thisAppt.sunday?
                while thisAppt <= lastAppt
                      puts "Working on time " + thisAppt.to_s(:db)
                      providers = allproviders
                      providers.each do |provider|  

                                
                                available =  provider.online
                                # don't override existing appointment
                                #puts provider.genie_id.to_s + "," + thisAppt.to_s + "," + available.to_s
                                  unless Slot.where(appointment: thisAppt.to_s(:db), doctor_id: provider.genie_id).first
                                      @slot = Slot.create(appointment: thisAppt.to_s(:db), doctor_id: provider.genie_id,  available: available)
                                  end
                              
                                 



                                


                      end
                      thisAppt = thisAppt + (15*60)

                end
                 
            end
            d=d+1
            startdate=startdate + 1.day
      end
      @pref = Pref.where(name: :lastAllAvailable).first
      @pref.value = thisAppt.strftime("%d/%m/%Y")
      @pref.save


end

def available?(reason,patient)
    returnValue = true
    if (reason != 'Online' or (reason == 'Online' and patient != 0)) and (reason != 'consult' or (reason == 'consult' and patient != 0)) and (reason != 'ROUTINE AT ANNEXE' or (reason == 'ROUTINE AT ANNEXE' and patient != 0)) and (reason != '' or (reason == '' and patient != 0))
        returnValue = false
    end
    return returnValue
end


end

