class PatientMailer < ActionMailer::Base
    add_template_helper(ApplicationHelper)

	default from: 'manager@alstonvilleclinic.com.au'
 
  def test_email
        mail(to: 'tony@practicecoach.com.au', subject: 'Welcome to Alstonville Clinic')
  end

  def clinic_booked(booker_id,booker2_id,email)
    @booker=Booker.find(booker_id)
    if booker2_id > 0 
    		@booker2=Booker.find(booker2_id)
    end
    mail(to: email, subject: 'Your ' + @booker.vaxtype+ ' booking at Alstonville CLinic')

  end

  def second_booked(booker_id,email)
    @booker=Booker.find(booker_id)
    mail(to: email, subject: 'Your Second ' + @booker.vaxtype+ ' booking at Alstonville CLinic')

  end


end


