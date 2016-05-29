module AppointmentsHelper
  def getTimeKey(h,m)
  	m=m.to_s
  	m="00" if m=="0"
  	return h.to_s + ":" + m
  end

  def getNextTimekey(timekey,closeTime=5)
  	    theArray=timekey.split(":")
  	    h=theArray[0].to_i
  	    mi=theArray[1].to_i
  	    mi=mi+15
  	    m=mi.to_s
  	    dayStillGoing=true
  	    if mi==60
  	    	h=h+1
  	    	if h==13
  	    		h=1
  	    	end
  	    	if h==closeTime
  	    		dayStillGoing=false 
  	    	end
  	    	m="00"
  	    end
  	    returnArray = [h.to_s.strip + ":" + m,dayStillGoing]
  	    return returnArray
 end

 def getNextDatekey(startDatekey)
  	    theDate = startDatekey.to_date
  	    theDate = theDate + 1.day
  	    return theDate.strftime("%Y-%m-%d")
 end

 def drawCalendar(datekey, noDays)
 	dayCount = 0
 	dateCol = getDateCol(datekey,noDays)
 	# draw Headers
 	theText="<table class='table table-striped table-bordered table-condensed'>\r"
 	theText += "\t<thead>\r\t<tr>\r\t\t<td></td>\r"
	while dayCount < noDays do 
		theText += "\t\t<th style='text-align:center' class='apptreason'>" + dateCol[dayCount].to_date.strftime("%a %d/%m") + "</th>\r"
		theText += "\t\t<th style='text-align:center' class='apptname'>" + dateCol[dayCount].to_date.strftime("%a %d/%m") + "</th>\r"

		dayCount += 1
	end
	theText += "\t</tr>\r</thead>\r"
	theText += "\t<tbody>\r"
	# draw Time and Appts
	timekey = "8:00"
	dayStillGoing = true
	i = 0
	while dayStillGoing do
		theText += "\t<tr>\r\t\t<td>" + timekey + "</td>\r"
		dayCount = 0
		while dayCount < noDays do 
			theText += "\t\t<td class='apptreason'>" 
			if  @appointments.key?(dateCol[dayCount]) and @appointments[dateCol[dayCount]].key?(timekey)
				 	theText += @appointments[dateCol[dayCount]][timekey]['reason']
			end
			theText+= "</td>\r"
			theText += "\t\t<td class='apptname'>" 
			if  @appointments.key?(dateCol[dayCount]) and @appointments[dateCol[dayCount]].key?(timekey)
				 	theText += @appointments[dateCol[dayCount]][timekey]['name']
			end
			theText+= "</td>\r"
			dayCount += 1
		end
		theText += "\t</tr>\r"
		returnArray = getNextTimekey(timekey)
		timekey = returnArray[0]
		dayStillGoing = returnArray[1]
	end
	theText += "\t</tbody>\r</table>\r"
	return theText
end

	def getDateCol(datekey,noDays)
		dayCount = 0
		dateCol = []
		while dayCount < noDays do 
			dateCol  << datekey
			datekey = getNextDatekey(datekey)
			dayCount += 1
		end
		return dateCol
	end


end
