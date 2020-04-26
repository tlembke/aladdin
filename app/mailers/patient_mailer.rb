class PatientMailer < ApplicationMailer

	 default from: 'tony@alstonvilleclinic.com.au'
 
  def test_email(patient,appointments,extras,consult)
    @patient=patient
    @appointmnents = appointments
    @changes=extras[0]
    @tasks=extras[1]
    @meds=extras[2]
    @notes=extras[3]
    @plan=extras[4]
    @tests=extras[5]
    @plan=extras[6]
    @consult =consult
    debugger
    mail(to: 'tlembke@gmail.com', subject: 'Welcome to Alstonville Clinic')
  end
end


