class Fax
  def initialize(username, password)  
    # Instance variables  
    @username = username 
    @password = password
    @baseURL = "https://api.fax2.com.au/v1/"
    @access_token = self.get_token
  end  
  
  def access_token
    @access_token
  end


  def get_token

      begin
      endPoint = "oauth2/token"
      response = RestClient.post "https://"+@username+":" + @password + "@api.fax2.com.au/v1/oauth2/token", {grant_type: 'client_credentials'}
        response2=JSON[response.body]
      
          access_token = response2["access_token"] 
        
       
      rescue
         access_token = ""
      end
      return access_token

  end

  def upload_text(theText)
    theUrl="https://api.fax2.com.au/v1/upload_document"
    # response = RestClient.post(theUrl, {theText.to_json}, {content_type: "text/plain", Authorization: "bearer " + access_token })
    response= RestClient::Request.execute(method: :post, url: theUrl,
                            payload: theText, headers: {content_type: "text/plain; charset=utf-8", Authorization: "bearer " + @access_token})
    response2=JSON[response.body]
    return response2


  end

  def upload_file(theFile)
    theUrl="https://api.fax2.com.au/v1/upload_document"
    begin
    # response = RestClient.post(theUrl, {theText.to_json}, {content_type: "text/plain", Authorization: "bearer " + access_token })
      response= RestClient::Request.execute(method: :post, url: theUrl,
                          payload: {:document => File.new(theFile, 'rb')}, headers: {Authorization: "bearer " + @access_token, content_type: "multipart/form-data"})
    #response = RestClient.post( theUrl, {:myfile => File.new(theFile, 'rb')}, headers: {Authorization: "bearer " + access_token, content_type: "multipart/form-data"})
    #response= RestClient::Request.execute(method: :post, url: theUrl,
       #                     payload: {:myfile => File.new(theFile, 'rb')}, headers: {content_type: "mutipart/form-data", Authorization: "bearer " + access_token})


    rescue RestClient::ExceptionWithResponse => err
        response2 = err.response


    end
  
    
  #request = RestClient::Request.new(
   #       :method => :post,
   #       :url => theUrl,
   #       :payload => {
   #         :file => File.new(theFile, 'rb')
   #       },
   #       :headers =>  {content_type: "multipart/form-data", Authorization:  "bearer " + access_token}
          
    #      )      
    #response = request.execute


    response2=JSON[response.body]
    return response2


  end

  def send_fax(dest_number,documents)
      theUrl="https://api.fax2.com.au/v1/send_fax"
      docText = ""
      documents.each do |document|
          docText = docText + "documents[]=" + document + "&"
      end
      docText = docText + "dest_number=" + dest_number
      begin
        response= RestClient::Request.execute(method: :post, url: theUrl,
                            payload: docText, headers: {Authorization: "bearer " + @access_token})
    	response2=JSON[response.body]

        rescue RestClient::ExceptionWithResponse => err
        response2 = err.response


    end

  end

  def self.normaliseFaxNumber(faxnumber)
  		faxnumber = faxnumber.gsub(/\s+/, "")
  		faxnumber = faxnumber.sub(/^0/, '')
  		if faxnumber.start_with?("66")
  			faxnumber = "2" + faxnumber
  		end
  		unless faxnumber.start_with?("61")
  			faxnumber = "61" + faxnumber
  		end


  		return faxnumber
  end

  def self.sendFax(f,faxNumber)
    		documents=[]
  			faxNumber = Fax.normaliseFaxNumber(faxNumber)
  			if Pref.faxsend == "true"
  				username= Pref.faxusername
  				password=Pref.decrypt_password(Pref.faxpassword)
  				thisFax = Fax.new(username,password)
  				response = thisFax.upload_file(f)
      			documents << response["document_id"]
      		
				@response=thisFax.send_fax(faxNumber,documents)
				FaxLog.info faxNumber + " " + File.basename(f) + " " + @response.to_s
			else
					@response = "Testing mode only"
			end

			# move fax to processed folder
			if @response["id"] and @response["id"] !=""
				# faxprocessed = Pref.faxprocessedfolder + "/" + File.basename(f)
				faxpending= Pref.faxpendingfolder + "/" + @response["id"] + File.extname(f)
				File.rename f, faxpending
				#change name of image file
				oldName = Rails.root.join('public','fax',File.basename(f, ".*")+ '.png')
				newName = Rails.root.join('public','fax',@response["id"] + '.png')
				# image.write(::Rails.root.join('public','fax',File.basename(f, ".*")+ '.png'))
				File.rename oldName, newName

			end
			return [f,faxNumber,@response]
   end


   def self.faxStatus(faxid,access_token)
  		
  		
   		
   		 		theUrl="https://api.fax2.com.au/v1/sent_faxes/"
    			# response = RestClient.post(theUrl, {theText.to_json}, {content_type: "text/plain", Authorization: "bearer " + access_token })
    	 		begin 
    	 			response= RestClient::Request.execute(method: :get, url: theUrl + faxid,
                            headers: {content_type: "application/json", Authorization: "bearer " + access_token})
    				response2 = JSON[response.body]
		        rescue RestClient::ExceptionWithResponse => err
		        	debugger
		        	response2 = err.response
    			end

    	return response2

   end
end  