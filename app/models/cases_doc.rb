class CasesDoc < ActiveRecord::Base
	belongs_to :doc
	belongs_to :case
end