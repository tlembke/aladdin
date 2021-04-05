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



def drawBookCalendar(startdate, noDays)
 	dayCount = 0
 	noDays = 1
 	# dateCol = getDateCol(datekey,noDays)
 	# draw Headers
 	  startTime = Pref.firstAppt.split(":")
      starthour = startTime[0].to_i
      startminute = startTime[1].to_i
      finishTime = Pref.lastAppt.split(":")
      finishhour = finishTime[0].to_i
      finishminute = finishTime[1].to_i

 	appts_per_day = (finishhour - starthour -1) * 4
 	appts_per_day = appts_per_day - 4 + ((60 - startminute)/15)
 	appts_per_day = appts_per_day  + ((60 - finishminute)/15)

 	theText="<table class='table tableRowHover table-bordered table-condensed table-compact table-responsive'>\r"
 	theText += "\t<thead>\r\t<tr>\r\t\t<th></th>\r"
 	thisdate=startdate
	while dayCount < noDays do 
		unless thisdate.saturday? or thisdate.sunday?
				theText += "\t\t<th style='text-align:center' colspan = '"  + appts_per_day.to_s + "'>" + thisdate.strftime("%A, %b %d") + "</th>\r"
				dayCount += 1
		end	
		thisdate = thisdate + 1
		
	end
	theText += "\t</tr>\r"
	theText += "</thead>\r"
	theText += "\t<tbody>\r"

	theText += "\r<tr>\r\t\t<td></td>\r"
	dayCount = 0
	thishour = starthour
	while dayCount < noDays do 
		unless thisdate.saturday? or thisdate.sunday?
				while thishour <= finishhour
					colspan = 4
					if thishour == starthour 
						colspan = (60 - startminute)/15
					end
					if thishour == finishhour 
						colspan = 1 + (finishminute/15)
					end
					theText += "\t\t<td colspan='"+ colspan.to_s + "'><span class='timecel'>"+ thishour.to_s + "</span></td>\r"
					thishour = thishour+ 1
				end
				dayCount += 1
		end	
		thisdate = thisdate + 1.day
		
	end

	theText += "\r</tr>\r"



	theText += "\r<tr>\r\t\t<td></td>\r"
	dayCount = 0
	thishour = starthour
	thisdate = startdate

	while dayCount < noDays do 
		unless thisdate.saturday? or thisdate.sunday?
				while thishour <= finishhour
					theText += "\t\t<td class='timecel'><span class='timecel'>00</span></td>\r" unless thishour == starthour and startminute >0
					theText += "\t\t<td class='timecel'><span class='timecel'>15</span></td>\r" unless (thishour == starthour and startminute >15) or (thishour==finishhour and finishminute <15)
					theText += "\t\t<td class='timecel'><span class='timecel'>30</span></td>\r" unless (thishour == starthour and startminute >30) or (thishour==finishhour and finishminute <30)
					theText += "\t\t<td class='timecel'><span class='timecel'>45</span></td>\r" unless thishour == finishhour and finishminute < 45
					thishour = thishour+ 1
				end
				dayCount += 1
		end	
		thisdate = thisdate + 1.day
		
	end

	theText += "\r</tr>\r"

	# now for each doctor
	
	providers=Provider.where(online: true)
	providers.each do |provider|
			theText += "\r<tr>\r\t\t"
			theText+= "\t\t<td>"+provider.name+"("+provider.genie_id.to_s+")</td>\r"
			dayCount = 0
			thisdate=startdate
			while dayCount < noDays do 
				thisAppt = Time.new(thisdate.year,thisdate.month, thisdate.day,starthour,startminute)
                lastAppt = Time.new(thisdate.year,thisdate.month, thisdate.day,finishhour,finishminute)
                

				unless thisAppt.saturday? or thisAppt.sunday?
						while thisAppt <= lastAppt
							apptInfoArray=apptInfo(thisAppt, provider.genie_id)
							apptReason = apptFree?(thisAppt, provider.genie_id)
							ar = apptInfoArray[1].downcase.tr(" ", "_").tr("*", "s").tr(".","s")
							apptInfoArray[0] ? thisClass='available' : thisClass=ar[0..9]
									theText += "\t\t<td data-toggle='tooltip' data-original-title='"+ thisClass + "-"  + apptInfoArray[2].to_s + "' class='" + thisClass + " consultslot"+"'></td>\r"					
							thisAppt = thisAppt + 15*60
						end
						dayCount += 1
				end	
				thisdate = thisdate + 1.day
				
			end
		theText += "\r</tr>\r"

	end







	
	


	theText += "\t</tbody>\r</table>\r"
	return theText
	end

	def apptInfo(thisAppt, doctor)
			returnArray=[]
			@slot = Slot.where(appointment: thisAppt, doctor_id: doctor).order(updated_at: :desc).all
			slotCount=@slot.length
	
			

			#begin
				reason = @slot[0].apptype.to_s
				reason = "Consult" if reason == "" or reason == nil
				if @slot[0].patient_name
					patient_name = @slot[0].patient_name
				else
					patient_name = ""
				end

				if slotCount > 1
					if @slot[1].patient_name
						patient_name = patient_name + " & " + @slot[1].patient_name
					end
				
					reason=reason + "(+" + slotCount.to_s + ")"
					@slot[0].available = false
					
				end
				
				return [@slot[0].available,reason,patient_name]
			#rescue
				#debugger
				#return [true,"Consult",""]
			#end
	end





end
