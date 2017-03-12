class RegisterPatient < ActiveRecord::Base
	belongs_to :patients
	belongs_to :registers
end