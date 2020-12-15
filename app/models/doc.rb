class Doc < ActiveRecord::Base
	has_and_belongs_to_many :tags
	attr_accessor :tag_string, :uploaded_doc
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
