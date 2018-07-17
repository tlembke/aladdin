class Chapter < ActiveRecord::Base
	belongs_to :section
	has_many :paragraphs
end
