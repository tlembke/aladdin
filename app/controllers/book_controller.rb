class BookController < ApplicationController
	skip_before_filter :require_login
	require "base64"
  require 'icalendar'


  def index
 

    
     params[:mode]=="v" ? @mode="v" : @mode="h"

     params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

  end


  def show_appt
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
    end

  params[:mode]=="v" ? @mode="v" : @mode="h"

     params[:noDays] ? @noDays=params[:noDays].to_i : @noDays=3

    

    

 

    
     if (@error_code==0)
    	  dbh=connect_array[0]

    	  @doctors= get_users(dbh)

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
          		 		 @appointments[doctor[2]]=[]
          		 		 freesCount = 0
          				 while i < @noDays
          				 	    while @thisDate.saturday? or @thisDate.sunday?
                          			@thisDate = @thisDate + 1.day
                      	end
          				 		 @thisCode=@thisDate.month*100 + @thisDate.day
          					  	@dateCodes<< [@thisCode,@thisDate] if firstPass

          					  	freeAppts = []

          					  	#apptArraySimple = findFrees(dbh,doctor[2],@thisDate)
          					  	apptArraySimple = findFreesWeb(connectionId,doctor[2],@thisDate)
              
          					  	apptArraySimple.each_with_index do |apptTime,j|
          					  			single=1
          					  			if j < apptArraySimple.length - 1 
                             
          					  				single =2 if apptTime[0] + 900.seconds== apptArraySimple[j+1][0]

          					  			end
          					  			apptCode = apptTime[0].hour * 100 + apptTime[0].min
          								  freeAppts << [apptCode, single,apptTime[1]]
          								
          					  	end

          			          #	@appointments[doctor[2]][@thisCode]=findFrees(dbh,doctor[2],@thisDate)

          			          	@appointments[doctor[2]][@thisCode] = freeAppts
          			          	freesCount = freesCount + @appointments[doctor[2]][@thisCode].length
          			         
          			          	@thisDate = @thisDate + 1.day

                    				i=i+1
          		          	
          		    end
          		         @doctorsFreesCount[doctor[2]] = freesCount

          		         if freesCount == 0
          		         	# there are no availabla appitmtnets in those days
          		         	#when is the next?
                          
          		         	#@nextAvailable[doctor[2]]=getThirdAvailable(dbh,doctor[2],@theStartDate,1,Date.today + 6.weeks)[0]
                        @nextAvailable[doctor[2]]=getNextWeb(connectionId,doctor[2],@theStartDate,Date.today + 8.weeks)
          		         end

          		
          		         firstPass = false


          	 end

          dbh.disconnect
          
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]
          debugger

  	 end
  	 
  	#end # temp bypass
   
      closeConnectionId(connectionId)

      render partial: "show_appt"
  end




  def show
  end

  def downloadcal
      

        @theDate = params[:date].to_date
        @theTime = params[:time].to_s


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
          e.summary     = "GP Appointment"
          e.description = params[:description]
          e.location    = "61 Main St, Alstonville NSW Australia"
        end

        send_data cal.to_ical, type: 'text/calendar', disposition: 'attachment', filename: filename

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

          if @patient_match == 2
              if @appt_id == "0" 
                  @errorId = saveApptTime(@patient[0],@patient[1],@patient[2],@doctor_id,@theDateTime,@duration)
                  
              else
                  #@errorId = saveApptSlot(@patient[0],@patient[1],@patient[2],@appt_id)
                  @errorId = saveApptTime(@patient[0],@patient[1],@patient[2],@doctor_id,@theDateTime,@duration)
              end

          else
          	@flash[:alert] =  "No patient"
          end




          
        

    	 
    	 dbh.disconnect        
     else
  				flash[:alert] = "Unable to connect to database. "+ get_odbc
  				flash[:notice] = connect_array[2]

  	 end

 
     if @patient_match == 2
        ApptLog.info params['appttime'] + ", duration " + @duration.to_s + " mins for " + @patient[0] + "," + @patient[1]
    		render :success
 	  else
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

	end

