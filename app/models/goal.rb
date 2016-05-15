class Goal < ActiveRecord::Base
	belongs_to :patient
	belongs_to :master
	belongs_to :measure
end
