class Result < ActiveRecord::Base

	def self.checked?(id)
		returnText = false
		if Result.where(result_id: id, result_date: Date.today).first
			returnText = true
		end
		return returnText

	end



  def self.get_result(id,dbh)

        sql = "SELECT Test, CollectionDate, HL7Type, Result FROM  DownloadedResult where Id =  " + id
 
          puts sql
         

          sth = dbh.run(sql)
               
          theresult=[]
          sth.fetch_hash do |row|

            	theresult =  row
          end




          
          

         
          sth.drop
          
          return theresult

  end 


end
