require 'test_helper'

class PatientMailerTest < ActionMailer::TestCase
  # test "the truth" do
  #   assert true
  # end
  def test_email
    PatientMailer.test_email
  end
end
