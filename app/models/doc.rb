class Doc < ActiveRecord::Base
	# A Doc is a file uploaded to Aladdin, or a reference to a document created in Aladdin, or a reference to a url
	has_and_belongs_to_many :tags
	attr_accessor :tag_string, :uploaded_doc


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


	class << self

		def in_order
	      order(created_at: :desc)
	    end

	    def recent(n)

	      in_order.endmost(n)
	    end

	    def endmost(n)
	      all.only(:order).from(all.reverse_order.limit(n), table_name)
	    end
  	end


	def save_tags(tag_string)
		# remove previous tags
		
		self.tags.delete_all
	   
		tags=tag_string.split(',')
		tags.each do |nexttag|
			@tag=Tag.find_by_name(nexttag.downcase.strip)
			unless @tag
				@tag=Tag.new(name: nexttag.downcase.strip)
				@tag.save
			end
			
			#add new tag
			self.tags << @tag
		end

	end
end
