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

  def check_symbol(status)
     color="danger"
     if status
        color="success" 
        icon= "fa-check"
      else
        color = "danger"
        icon ="fa-times"
    end
                 
    theText = "<a class='btn btn-small btn-" + color + "'><i class='fa " + icon +"'</a>"
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

  def billing_symbol(status,message = "&nbsp;")
           color=""
         color="btn-inverse" if status == 8
         color="btn-danger" if status == 5
         color="btn-success" if status == 6
         color="" if status == 7
         color="btn-info" if status == 4
          theText = "<a class='btn btn-small " + color + "'>" + message + "</a>"
          return theText.html_safe
  end




end
