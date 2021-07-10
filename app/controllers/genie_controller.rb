class GenieController < ApplicationController
  require 'odbc'


 

  def login
  	reset_session
    if params[:restart]
          system ("passenger-config restart-app /Users/cpd/Projects/")
          system ("/usr/sbin/apachectl graceful")
          # this need _www ALL = NOPASSWD: /usr/sbin/apachectl to be added to /etc/sudoer using visudo command as root
          puts "Restarting Aladdin using passenger-config and apachectl"
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
                  system ("/usr/sbin/apachectl graceful")

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
              # test for medium stength  at least a lowercase letter, a uppercase, a digit and 8+ chars
              unless @password[/^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$/]
                  flash[:alert] = "Your password needs to be changed in Genie so that it has at least a lowercase letter, an uppercase letter, a digit and 8+ chars"
                  flash[:notice] = "Please  go to Genie > File > Add or Change User > Set Password"
              end
              session[:id]=@id
              session[:name]=@name
        		 	session[:username] = @username
              crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
              @password = crypt.encrypt_and_sign(@password)
        		 	session[:password] = @password
              session[:provider] = @provider
              #session[:id] = id
              #session[:name] = name
        		 	# 10 * 60 = 10 minutes
        		 	session[:expires_at] = Time.current + 180.minutes
              dbh.disconnect
        		 	redirect_to root_url
        		  
        	  end

        end

      end
   end

   def dashboard
         redis_check  = `ps ax | grep "[r]edis"`
         redis_check.blank? ? @redis = "Not running" : @redis = "Running"
         sidekiq_check  = `ps ax | grep "[s]idekiq"`
         sidekiq_check.blank? ? @sidekiq = "Not running ... will restart" : @sidekiq = "Running"
         if sidekiq_check.blank?
              system("#{Rails.root}/start_sidekiq.sh")
         end




   end





  private



end
