module ApplicationHelper
  def app_name
    "Aladdin"
  end

  def status_symbol(status="green",message="OK")
    # message= "" if message == nil
		 color="success"
      	 color="warning" if status=="orange"
         color="danger" if status == "red"
          theText = "<a class='btn btn-small btn-" + color + "'>" + message + "</a>"
          return theText.html_safe
  end

  def check_symbol(status)
     color="danger"
     if status
        color="success" 
        icon= "fa-check"
      else
        color = "danger"
        icon ="fa-times"
    end
                 
    theText = "<a class='btn btn-small btn-" + color + "'><i class='fa " + icon +"'</a>"
          return theText.html_safe
  end

  def alcohol_display(alcoholstatus,patient)
      status="green"
      status="orange" if  alcoholstatus[patient] == "Unsafe"
      status="red" if  alcoholstatus[patient] == "Very Unsafe"
      
      return status_symbol(status,alcoholstatus[patient])
  end

  def age(dob)
    begin
      now = Time.now.utc.to_date
      age =  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    rescue
       
        age=0
    end
    return age
  end

    def age_months(dob)
   # begin
      now = Time.now.utc.to_date
     # age =  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
     # rescue
     #  age=0
    #  end
    # ageStr = age.to_s + "years"
    #  if age < 2
          age = (now.year - dob.year) * 12 + now.month - dob.month - (now.day >= dob.day ? 0 : 1)
          ageStr = age.to_s + " month".pluralize(age)

          if age > 23
              age = (age/12).abs
              
              ageStr = age.to_s + " years"

          end

     # end
     #rescue
      #    ageStr = "0"
     # end


    return ageStr
  end

  def billing_symbol(status,message = "&nbsp;")
           color=""
         color="btn-outline-inverse" if status == 8
         color="btn-danger" if status == 5
         color="btn-success" if status == 6
         color="" if status == 7
         color="btn-info" if status == 4
          theText = "<a class='btn btn-small " + color + "'>" + message + "</a>"
          return theText.html_safe
  end

  def whats_due(itemNumbers)
    returnText = ""
    reviewFlag = true

    if itemNumbers['721'] == nil  or (itemNumbers['721'] != nil and Time.now >  itemNumbers['721'] + 12.months)
      returnText =returnText + "<button class='btn btn-xs btn-success'>721</button>"
      reviewFlag=false
    end
    if itemNumbers['723'] == nil   or (itemNumbers['723'] != nil and Time.now >  itemNumbers['723'] + 12.months)
      returnText =returnText + "<button class='btn btn-xs btn-success'>723</button>"
      reviewFlag=false
    end
    if reviewFlag and (itemNumbers['732'] == nil or (itemNumbers['732'] != nil and Time.now >  itemNumbers['732'] + 3.months) )
      returnText =returnText + "<button class='btn btn-xs btn-success'>732</button>"
      
    end

    return returnText.html_safe
  end

  def showEvery(number,unit,question=true)
     unit = "" unless unit
     if unit != ""
        if number and number !="" and number > 1
          unit = pluralize(number, unit)
        end
     end
     unit="?" if unit == "" and question

        
     return unit

  end

  def showNext(day,month,year,question=true)
     theText = ""
     begin
          theDate=Date.new(year,month,day)
          theText = theDate.strftime("%b %d, %Y")
     rescue
        if question and (day== "" or day == 0 or day==nil) and (month == 0 or month=="" or month==nil ) and (year == "" or year ==0 or year == nil)
            theText = "?"
        else
          if (day!="" and  day != 0 and day!=nil)

              theText =  theText + day.to_s + ""
          end
          if (month != 0 and month!="" and month!=nil )
            theText=theText+ Date::MONTHNAMES[month][0..2]  + ", "
          end
        end
        theText = theText+ year.to_s if year != "0"
     end
     theText = "?" if theText == "?0"

     return theText

  end

  def actionIcon(cat)
    icon="fa fa-medkit"
    icon="fa fa-user-md" if cat == 0 
    icon="fa fa-stethoscope" if cat ==4
    icon="fa fa-heartbeat" if cat ==3
    icon="fa fa-hospital-o" if cat ==2

    return icon

  end

  def actionplans_for_select     
      Document.where(code: 1, patient_id: 0).collect { |m| [m.name, m.id] }
  end

   def breaking_wrap_wrap(txt, col = 80)
        txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,"\\1\\3\n") 
   end

   def decode(msg)
        #convert from hex to text
        
        msg = [msg].pack('H*')
    
        msg2 = msg.rpartition('</plist>').last
        msg3 = msg2.force_encoding("ASCII-8BIT").encode('UTF-8', undef: :replace, replace: '')

        msg4=msg3.gsub(/[\u{0000}-\u{0008}]/,"")
        msg4=msg4.gsub(/[\u{0011}-\u{0014}]/,"")
        fonts=["New York","Lucida Grande","Times New Roman"]
        fonts.each do |font|
          
          if msg4.include?(font)
            msg4 = msg4.rpartition(font).last
          end
        end

        
        #msg2 = msg2.gsub("\n", "")
        #msg2 = msg2.gsub("IRPMx","")
        # change bold text delimiters
        msg4=bolden(msg4)
        
      

          
      
       # msg3 = msg2.rpartition(msg2.scan(/~SBLD.+$/).last).last
        return msg4

   end

   def bolden(msg)
     
        msg=msg.gsub("\\N\\","</b>")
        msg=msg.gsub("\\H\\","<b>")
        msg=msg.gsub("E\\","")
        msg=msg.gsub("\\E","")
        msg=msg.gsub("\\T\\ndash;"," - ")
        msg=msg.gsub('>BBBB"','&nbsp;&nbsp;&nbsp;•')
        msg=msg.gsub('>AAAA','')
        theStr="#\$\\"
        msg=msg.gsub(theStr,"")
        theStr="#\$"
        msg=msg.gsub(theStr,"")
        
        msg=msg.gsub('@8@q','<b>')
         msg=msg.gsub('@8@U','</b>')
         msg=msg.gsub(/>.+?BBM/,"&nbsp;&nbsp;&nbsp;M")
         #msg=msg.gsub(/>A.+{3}C/,"")
         msg=msg.gsub(/C\*.+?\s/," ")
         msg=msg.gsub(/C\$/," ")
       
         msg=msg.gsub(/@@+\s/,"")
         msg=msg.gsub('>OAOACCC','')
         msg=msg.gsub('>SASA','')

       
         


         
         



         #msg=msg.gsub(/>...A/,"&nbsp;&nbsp;&nbsp;")
       
  

        return msg
   end


end
