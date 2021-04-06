class ApplicationMailer < ActionMailer::Base
  default from: "tony@lemlink.com.au"

def test_email_2
	mail(to: 'tlembke@gmail.com', subject: 'Welcome to Alstonville Clinic')
	end
end
