class PatientMailer < ActionMailer::Base
    add_template_helper(ApplicationHelper)

	default from: 'manager@alstonvilleclinic.com.au'
 
  def test_email
        mail(to: 'tony@practicecoach.com.au', subject: 'Welcome to Alstonville Clinic')
  end

  def clinic_booked(booker,email)
    @booker=booker
    mail(to: email, subject: 'Your ' + @booker.vaxtype+ ' booking at Alstonville CLinic')

  end
end


