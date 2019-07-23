class GenieController < ApplicationController
  require 'odbc'


 

  def login
  	session[:username]=nil
  	session[:password]=nil
    if params[:restart]
          # system ("passenger-config restart-app /Users/cpd/Projects/")
          connect=false
          flash[:notice]="Aladdin restarted"
    else
          @odbc_text=get_odbc
          flash[:connect]=@odbc_text[1]
        	if request.post?
        		@username=params[:name]
        		@password=params[:password]
        		@error_msg=""
        		dsn_name=""
        		connect=true

        		begin
        			dsns= ODBC.datasources
        			dsn_name= dsns[0].name
        			puts "Connecting to " + dsn_name

            rescue
            			flash[:notice]="Unable to find dsn. Have you configured iODBC? I will restart Alladin so try again"
                  system ("touch #{Rails.root}/tmp/restart.txt")

                  system ("passenger-config restart-app /Users/cpd/Projects/")
            			connect=false

            			#redirect_to controller: "genie", action: "login"
            end
            if connect
                  begin
      			           dbh=ODBC.connect(dsn_name,@username,@password)
                  rescue
        			         connect=false
        			         if ODBC.error[0].include? "Authentication failed"
        				            flash[:alert] = "Username / password failed."
        				#redirect_to({controller: "genie", action: "login"}, notice: "Username / password failed")
        			         else
        				            flash[:alert] = "Unable to connect to database. "+get_odbc
                            flash[:notice] =  ODBC.error[0]
      				#redirect_to({controller: "genie", action: "login"}, notice: ODBC.error[0])
                       end
      			      end
            end

        	
        		# logged in
        		if connect
                sql = "SELECT Id, Name, ProviderNum FROM Preference where Username  = '%s'" % @username
                puts sql

                sth = dbh.run(sql)
                @error = ODBC.error

               
                sth.fetch do |row|

                    @name=row[1]
                    @id=row[0]
                    @provider=row[2]

                end
                sth.drop
              session[:id]=@id
              session[:name]=@name
        		 	session[:username] = @username
        		 	session[:password] = @password
              session[:provider] = @provider
              #session[:id] = id
              #session[:name] = name
        		 	# 10 * 60 = 10 minutes
        		 	session[:expires_at] = Time.current + 120*60
              dbh.disconnect
        		 	redirect_to root_url
        		  
        	  end

        end

      end
   end





  private



end
