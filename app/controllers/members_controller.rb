class MembersController < ApplicationController

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    @member = Member.find(params[:id])

    if params[:member][:note]
        @member.note = params[:member][:note]
    end
    # process text in everyUnit to convert to number and unit
    if params[:member][:everyUnit] or params[:member][:nextDay]

      @member.everyNumber, @member.everyUnit = processEvery(params[:member][:everyUnit])
          #process text in nextDay to convert to day month and year

      @member.nextDay,@member.nextMonth,@member.nextYear,@member.exactDate = processNext(params[:member][:nextDay])
    end
   
    respond_to do |format|

          if @member.save
            format.js {}
            format.html 
            format.json { head :no_content } # 204 No Content
          else
            format.html { render :edit }
            format.json { render json: @member.errors, status: :unprocessable_entity }
          end 
      
    end
  end



  def show
  end

  # GET /members/new
  def new
    # this will only be for recalls
    @member = Member.new
    @member.patient_id = params[:patient_id]
    @recalls = Recall.all
  end

  # GET /members/1/edit
  def edit
  end

  # POST /recalls
  # POST /recalls.json
  def create
    
    @member = Member.new(member_params)
    @member.recallflag = true
   
    respond_to do |format|
      if @member.save
        format.js {}
        format.html { redirect_to @member, notice: 'Recall was successfully created.' }
        format.json { render :show, status: :created, location: @patient_recall }

      else
        format.html { render :new }
        format.json { render json: @patient_recall.errors, status: :unprocessable_entity }
      end
    end
  end

 # DELETE /members/1
  def destroy
    @member = Member.find(params[:id])
    @member.destroy

     render :nothing => true

    
  end



  private
  def member_params
      params.require(:member).permit(:patient_id, :genie_id, :note,:year_reset,:epc,:everyUnit,:everyNumber,:nextDay,:nextMonth,:nextYear, :exactDate, :recall)
  end

  def processEvery(theText)
      # is it blank
      if theText == "" or theText =="?"
          number=0
          unit = ""
      else 
        # change numbers as words to digits
         theText = wordToNumber(theText)
         m = theText.match /(\d*)\s*(\D*)/
         number=m[1]
         unit=m[2]
         number = 1 if number==""
         number=number.to_i
         unit = "day" if unit[0] == "d"
         unit = "week" if unit[0] == "w"
         unit = "month" if unit[0] == "m" or unit == "" # default
         unit = "year" if unit[0] == "y"
      end
      return number, unit
  end

   def processNext(theText)
      # is it blank
      if theText == "" or theText =="?"
          theDay=0
          theMonth=0
          theYear=0
      else 
         # change numbers as words to digits

         theText = wordToNumber(theText)
         theText = theText.gsub("next","1")
        
         m = theText.match /^(\d+)\D(\d+)\D*(\d*)/
     
         if m
            # 12/4/2019
            
            exactDate=true
            theDay=m[1]
            theMonth=m[2]
            theYear = m[3]
            if theYear == ""
              # check its not 8/2020
              if theMonth.to_i>12
                  theDay=0
                  theMonth=m[1]
                  theYear=m[2]
                  exactDate=false
              else  

                theYear = Time.now.year
                
                theDate = Date.new(theYear.to_i, theMonth.to_i, theDay.to_i)
                if theDate < Time.now
                  theYear=theYear+1
                end

              end
            end
            



     
         else 
               m = theText.match /\s*(\D*)(\d*)(\S*)\s*(\D*)(\d*)/
               if m
                    type=0
                    m3=m[3].downcase
                    if m3[0]=="d" or m3[0] =="w" or m3[0] =="y" or (m3[0] =="m" and m3[0..1] != "ma") 
                      theUnit=m3[0]
                      type=1
                    end
                    m4=m[4].downcase
                    if m4[0]=="d" or m4[0] =="w" or m4[0] =="y" or (m4[0] =="m" and m4[0..1] != "ma") 
                      theUnit=m4[0]
                      type=1
                    end
                    m1=m[1].downcase
                    if (m1[0]=="d" and m1[0..1] !="de") or m1[0] =="w" or m1[0] =="y" or (m1[0] =="m" and m1[0..1] != "ma") 
                      theUnit=m1[0]
                      type=1
                    end
                    if type==1 
                      next_date=Date.today
                      number=m[2].to_i
                      number = 1 if number == "" or number == 0
                     
                      case theUnit
                      when "m"
                          next_date=next_date+number.months
                      when "w"
                          next_date=next_date+number.weeks
                      when "d"
                          next_date=next_date+number.days
                      when "y"
                          next_date=next_date+number.years
                      end
                      theDay=next_date.day
                      theMonth=next_date.month
                      theYear=next_date.year
                      exactDate=false
                   

                    else
                      # 4th May 2020
                      if m[1] != ""
                        theMonth = m[1]
                      else
                        theMonth =m[4]
                      end
                      exactDate = true
                      theDay = m[2]
                      if theDay.to_i > 1999
                        theYear =m[2]
                        theDay=0
                      else
                        theYear=m[5]
                      end
                      theDay = 0 if theDay == ""
                  
              
                      theMonth = convertMonth(theMonth) # this is a string and will need to be converted
                      theYear = convertYear(theYear,theMonth)
                      exactDate = false if theDay == 0
                    end
                    
               end
          end

      end
      return theDay,theMonth,theYear,exactDate
  end

  def convertMonth(month)
    theMonth=0
    month=month.downcase
    theMonth = 1 if month[0..1] == "ja"
    theMonth = 2 if month[0..1] == "fe"
    theMonth = 3 if month[0..2] == "mar"
    theMonth = 4 if month[0..1] == "ap"
    theMonth = 5 if month[0..2] == "may"
    theMonth = 6 if month[0..2] == "jun"
    theMonth = 7 if month[0..2] == "jul"
    theMonth = 8 if month[0..1] == "au"
    theMonth = 9 if month[0..1] == "se"
    theMonth = 10 if month[0..1] == "oc"
    theMonth = 11 if month[0..1] == "no"
    theMonth = 12 if month[0..1] == "de"
    return theMonth
  end

  def convertYear(year,month)
    theYear = year
    if year == ""
      theYear =Time.now.year
      if month < Time.now.month
        theYear = theYear + 1
      end 
    end
    return theYear
  end

 
    def wordToNumber(newText)
      numbers = %w{one two three four five six seven eight nine ten eleven twelve}
      count=1
      for i in numbers do
          newText=newText.gsub(i,count.to_s)
          count=count+1
      end
      return newText
    end








end


