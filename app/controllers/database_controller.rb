class DatabaseController < ApplicationController

 def index
 	 @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)  
          dbh=connect_array[0]


                # default is
                sth1 = dbh.tables

                @tables = sth1.fetch_all

                # @newtables=['Enclosure']


                

              
               # @tables.each do |table| 

                #       @sth2 = dbh.columns(table[2])
               #       @columns << @sth2.fetch_all
                #end
                    
                dbh.disconnect
      

     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end

 end

 def columns

     @username = session[:username]
     @password = session[:password]
     @id=session[:id]
     @name=session[:name]

     connect_array=connect()
     @error_code=connect_array[1]
     if (@error_code==0)  
          dbh=connect_array[0]




                # @newtables=['Enclosure']
             
                @sth2 = dbh.columns

                @columns =  @sth2.fetch_all

                

              
               # @tables.each do |table| 

                #       @sth2 = dbh.columns(table[2])
               #       @columns << @sth2.fetch_all
                #end
                    
                dbh.disconnect
      

     else
          flash[:alert] = "Unable to connect to database. "+ get_odbc
          flash[:notice] = connect_array[2]
          redirect_to  action: "login"
     end



  end

  def table
  	 if params[:table]

		     @username = session[:username]
		     @password = session[:password]
		     @id=session[:id]
		     @name=session[:name]

		     connect_array=connect()
		     @error_code=connect_array[1]
		     if (@error_code==0)  
		          dbh=connect_array[0]



		          		

		                # @newtables=['Enclosure']
		             
		                sth2 = dbh.columns(params[:table])

		                @columns =  sth2.fetch_all


		                @table=params[:table]

		                sql= "SELECT Count(*) from " + @table
		                puts sql
          				sth = dbh.run(sql)
          				@count = sth.fetch[0]

          				if request.post?
          					# get all columns
          					@columnSt =""
          					intCol = false
          					@columns.each_with_index do |column,i|
          						@columnSt=@columnSt + column[3]
          						if i + 1 < @columns.count
          							@columnSt = @columnSt + ","
          						end
          						if column[3] == params[:column]
          							if column[5].starts_with?("INT")
          								intCol = true
          							end
          						end
          					end
          					# is it in integer columns


          					if params[:column] and params[:value]
          							if intCol
          								@sql= "SELECT " + @columnSt + " from " + @table + " where " + params[:column] + " = " + params[:value]
          							else
          								@sql= "SELECT " + @columnSt + " from " + @table + " where " + params[:column] + " = " + "'" + params[:value] +"'"
          						
          							end
          							sth3 = dbh.run(@sql)
          							@result = []
          							if params[:number] == "All"
          								sth3.fetch_hash do |row|
          									@result << row
          								end
          							else
          								@result << sth3.fetch_hash
          							end
          						
          						


          					end


          				end
          				

		               

		              
		               # @tables.each do |table| 

		                #       @sth2 = dbh.columns(table[2])
		               #       @columns << @sth2.fetch_all
		                #end
		                    
		                dbh.disconnect
		               
		      

		     else
		          flash[:alert] = "Unable to connect to database. "+ get_odbc
		          flash[:notice] = connect_array[2]
		          redirect_to  action: "login"
		     end

	 else
	 		flash[:alert] = "No table selected"
	 		redirect_to  action: "index"

	 end

  end
end
