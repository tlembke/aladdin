class Header < ActiveRecord::Base
	has_many :cells
	belongs_to :register

end
