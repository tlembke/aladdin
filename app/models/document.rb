class Document < ActiveRecord::Base
	belongs_to :patient
	belongs_to :doc



#document.rb
# these are Aladdin documents, which use  'code', and may be assocaied  with a particular patient through patient:
# templates have a parent: 0
	#1 Action Plans   ==   1
	#2 Patient Information  == 1 
	#3 Policy == 4
	#4 Notes ==3
#docs.rb 
#these are a combination of uploaded documents, Aladdin documents and urls and use cat:
	#1 Handout
	#2 Form
	#3 Resource
	#4 Policy

end
