class ReminderWorker
  include Sidekiq::Worker

  def perform()
    # send reminder emails to everyone with an appointment today

    #testing purposes, send me an email 
    PatientMailer.test_email.deliver_later
  end
end
