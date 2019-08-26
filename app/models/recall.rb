class Recall < ActiveRecord::Base

	  def self.cats
  		return 'Appointment, Blood Test, Radiology, Test, Check, Treatment'.split(',')
  	  end

  	  def self.options
  	  	theText=""
  	  	@recalls=Recall.order(:cat)
  	  	currentCat = -1
  	  	@recalls.each do |recall|
  	  		if recall.cat != currentCat
  	  			theText=theText+"<optgroup label='"+ Recall.cats[recall.cat] + "'>\n"
  	  			currentCat = recall.cat
  	  		end
  	  		theText=theText + "<option value='"+ recall.id.to_s + "'>"+recall.title+"</option>\n"
  	  		if recall.cat != currentCat
  	  			theText=theText+"</optgroup>\n"
  	  		end
  	  	end
  	  	return theText.html_safe

  	  end

end
