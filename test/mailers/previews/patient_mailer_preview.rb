# Preview all emails at http://localhost:3000/rails/mailers/patient_mailer
class PatientMailerPreview < ActionMailer::Preview
  def test_email_preview
    PatientMailer.test_email
  end
end
