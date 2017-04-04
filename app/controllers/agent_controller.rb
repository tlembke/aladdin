class AgentController < ApplicationController
	require 'odbc'
	# This controller receives a change in window from Genie and opens the patinet dashboard
  def index

		connect_array=connect()
        @error_code=connect_array[1]
        if (@error_code==0)
        	  @id=0
      			if params[:p]
      				dbh=connect_array[0]
    	  			@p=params[:p]
    		  		#bits=@p.match(/?<name>.*)\((?<day>\d{1,2})\/(?<month>\d{1,2})\/(?<year>\d{4}/)
    		  		#bits=@p.match(/(.*)\((\d+)\/(\d+)\/(\d+)/)
    		  		bits=@p.match(/(?<name>.*)\s\((?<day>\d+)\/(?<month>\d+)\/(?<year>\d+)/)
              if bits
              		  		titles=%w(Mr Mrs Ms Miss Dr Prof Master)
              		  		@names=bits['name'].split
              		  		titles.each do |title|
              		  			if @names[0]==title
              		  				@names.shift
              		  			end
              		  		end

              		  		# now find patient 
              		  		# first name starts with @name[0]
              		  		# surname end with @name.last
              		  		# dob is bits['day']/bits['month']/bits['year']
              		  		surname= "%" + @names.last
              		  		firstname = @names[0] + "%"
              		  		where_clause = "Surname LIKE '" + surname + "' and FirstName LIKE '" + firstname + "'"
              		  		year = 2000 + bits['year'].to_i
              		  		if year > Time.now.year
              		  			year = year -100
              		  		end
              		  		dob = Date.new(year,bits['month'].to_i,bits['day'].to_i)
              		  		where_clause += " and DOB = '"+dob.to_s(:db)+"'"
              		  		sql = "SELECT id FROM Patient WHERE " + where_clause
                        puts sql
                        sth = dbh.run(sql)
                        @id=0
                        sth.fetch do |row|
                          		  @id = row[0]
                        end

                        sth.drop
                          

                        d=params[:d]
                        @controller="patient"
                        if d == "Care Plan"
                        	@action = "careplan"
                        elsif d == "Annual Check"
                        	@action = "annual"
                        elsif d == "Health Summary"
                        	@action = "healthsummary"
                        elsif d == "Consultation Summary"
                        	@action = "show"
                        end
                        if d == "Nursing Home"
                        	@controller = "nursinghome"
                        	@action = "index"
                        end
                        if d == "Appointments"
                        	@controller = "appointments"
                        	@action = "index"
                        end
                        if d == "Aladdin"
                        	@controller = "patient"
                        	@action = "index"
                        end

               end # end bits
            end # end params p


            dbh.disconnect

    		  	

		else  # error
          # lost connection to database
      
          flash[:notice]=connect_array[2]
          redirect_to  action: "login" and return
    	end	
      
    	if @id != 0 
    	       redirect_to  controller: @controller, action: @action, id: @id
      else
             redirect_to  controller: "patient", action: "index"
      end

 	end# end index 
  

end 
