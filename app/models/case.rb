class Case < ActiveRecord::Base
	self.primary_key ='code'
	belongs_to :patient
	has_and_belongs_to_many :docs

end
