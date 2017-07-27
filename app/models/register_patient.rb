class RegisterPatient < ActiveRecord::Base
	belongs_to :patient
	belongs_to :register
end