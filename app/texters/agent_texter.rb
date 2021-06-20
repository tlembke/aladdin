class AgentTexter < Textris::Base
  default :twilio_messaging_service_sid => "MG29a2a17ef84e61016b1b8da697e82348"
  default :from => "+61488825504"


  def alert(params)
    @params = params
    text :to => params[:mobile]

  end

  def reminder(params)
     @params = params
     text :to => params[:mobile]
  end
end

