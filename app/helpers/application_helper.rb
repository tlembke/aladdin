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



end
