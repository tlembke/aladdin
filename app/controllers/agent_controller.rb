class AgentController < ApplicationController
	require 'odbc'
	# This controller receives a change in window from Genie and opens the patinet dashboard
  def index

		connect_array=connect()
        @error_code=connect_array[1]
        if (@error_code==0)
        	@id=""
  			if params[:p]
  				dbh=connect_array[0]
	  			@p=params[:p]
		  		#bits=@p.match(/?<name>.*)\((?<day>\d{1,2})\/(?<month>\d{1,2})\/(?<year>\d{4}/)
		  		#bits=@p.match(/(.*)\((\d+)\/(\d+)\/(\d+)/)
		  		bits=@p.match(/(?<name>.*)\s\((?<day>\d+)\/(?<month>\d+)\/(?<year>\d+)/)
		  		titles=%w(Mr Mrs Ms Miss Dr Prof)
		  		@names=bits['name'].split
		  		titles.each do |title|
		  			if @names[0]==title
		  				@names.shift
		  			end
		  		end
            puts 'here'
		  		# now find patient 
		  		# first name starts with @name[0]
		  		# surname end with @name.last
		  		# dob is bits['day']/bits['month']/bits['year']
		  		surname= "%" + @names.last
		  		firstname = @names[0] + "%"
		  		where_clause = "Surname LIKE '" + surname + "' and FirstName LIKE '" + firstname + "'"
		  		year = bits['year'].to_i

          if year  < 100
            year = year + 2000
		  		  if year > Time.now.year
		  			      year = year -100
		  		  end
          end
		  		dob = Date.new(year,bits['month'].to_i,bits['day'].to_i)
		  		where_clause += " and DOB = '"+dob.to_s(:db)+"'"
          @dob=dob.to_s
		  		sql = "SELECT id FROM Patient WHERE " + where_clause
                puts sql

                sth = dbh.run(sql)
           	
                sth.fetch do |row|
            		@id = row[0]
          		end

                sth.drop
             end

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



		  	

		else
          # lost connection to database
      
          flash[:notice]=connect_array[2]
          redirect_to  action: "login" and return
    	end	
    	
    	redirect_to  controller: @controller, action: @action, id: @id

 	end# end index 
  

end 
