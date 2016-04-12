class ApplicationController < ActionController::Base
  require 'odbc'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login, :except => [:login,:error]


private

  def require_login
    if session[:username] and Time.current < session[:expires_at]
       session[:expires_at] = Time.current + 20*60
    else
      if session[:expires_at] && Time.current >= session[:expires_at]
      	   flash[:alert] = "Session expired due to inactivity"
      end
      redirect_to controller: "genie", action: "login"
    end
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
      end
      # logged in
      # this next line is inconsistent so dropped
      dbh.use_time = true
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
