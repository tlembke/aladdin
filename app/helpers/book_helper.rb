module BookHelper
	 def to_simple_time(theTimeCode)
	 		theHour=theTimeCode/100.ceil
	 		theMorn="am"
	 		if theHour>=12 
	 			theMorn="pm"
	 			if theHour >=13
	 				theHour=theHour-12
	 			end
	 		end
	 		theMin=theTimeCode.to_s[-2..-1]
	 		theTime = theHour.to_s + ":" + theMin + theMorn
	 		if theHour < 10
	 			theTime = ""+theTime
	 		end
	 		return theTime.html_safe
	 end


	 def downarrowshow(i,count,display,direction)
	 		if direction == 'down'
	 			j=i+1
	 			#j=0 if j>= count
	 		else
	 			j= i + display -1
	 			#j=0 if j >= count
	 		end
	 		return j
	 end

	 def downarrowhide(i,count,display,direction)
	 		if direction == 'down'
	 			j=i
	 		else
				j=i+display
	 		end
	 		return j

	 end
	 def uparrowshow(i,count,display,direction)
	 		 if direction == 'down'
	 			j=i-display+1
	 		else
	 			j= i-1
	 		end
	 		return j

	 end
	 def uparrowhide(i,count,display,direction)
	 		if direction =='down'
	 			j=i-display
	 		else
	 			j= i
	 		end
	 		return j

	 end
	 def hide(i,count,display,direction)
	 		if direction=="up"
	 	    	j=i+display
	 	    else
	 	    	j=i-display
	 	    end
	 	    return j


	 end
	 def show(i,count,display,direction)
	 	    if direction == "up"
	 	    	j=i-1
	 	    else
	 	    	j=i+1
	 	    end
	 	    return j

	 end



end
