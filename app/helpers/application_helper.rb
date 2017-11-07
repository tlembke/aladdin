module ApplicationHelper
  def app_name
    "Aladdin"
  end

  def status_symbol(status="green",message="OK")
		 color="success"
      	 color="warning" if status=="orange"
         color="danger" if status == "red"
                 
          theText = "<a class='btn btn-small btn-" + color + "'>" + message + "</a>"
          return theText.html_safe
  end

  def age(dob)
    begin
      now = Time.now.utc.to_date
      age =  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    rescue
       
        age=0
    end
    return age
  end



end
