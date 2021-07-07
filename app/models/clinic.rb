class Clinic < ActiveRecord::Base
	has_many :bookers, -> { order 'bookhour, bookminute' }
	has_many :groups
	belongs_to :group
  belongs_to :clinic, foreign_key: :pair1


	#attr_accessor :groups

	def self.initialize
		@groups = groups

	end

	def self.findAllGroups(vaxType="Fluvax")

		@allClinics = Clinic.where("vaxtype LIKE ? and clinicdate >= ?",vaxType+"%",Date.today).order(:clinicdate).all

		return @allClinics


	end

  def self.findAllActiveGroups(vaxType="Fluvax")

    @allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ?",vaxType,Date.today,true).order(:clinicdate).all

    return @allClinics


  end
    def self.findAllFilteredGroups(vaxType,status,invite)
        if status == "Old"
            if invite == true
                @allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ?",vaxType,Date.today,true).order(:clinicdate).all
            else
                @allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ? and inviteold = ?",vaxType,Date.today,true,false).order(:clinicdate).all
            end
        else
            if invite == true
                @allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ? and shownew = ?",vaxType,Date.today,true,true).order(:clinicdate).all
            else
                @allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ? and shownew = ? and invitenew = ?",vaxType,Date.today,true,true,false).order(:clinicdate).all
            end
        end

        return @allClinics

    end


	def groups
 			hourCount= self.starthour
 			
 			groups=[]
 			while hourCount <= self.finishhour
 					hourCount == self.starthour ? minCount = self.startminute : minCount = 0

    				while minCount < 60  and !(minCount >=self.finishminute and hourCount == self.finishhour)
	          
	     				bookerCount = self.bookers.where(bookhour: hourCount, bookminute: minCount).count
	     				Group.new(self.id,hourCount,minCount,bookerCount,self.people - bookerCount)
	     				groups << Group.new(self.id,hourCount,minCount,bookerCount,self.people - bookerCount)
	      			    minCount = minCount + ( 60  / self.perhour)
      				end		
     				hourCount = hourCount + 1			
  			end
  			return groups
  			
      

    end

    def isBreak?(theHour,theMinute)

      returnValue = false
      if self.break
          bStart = self.bstarthour * 1000 + self.bstartminute
          bFinish = self.bfinishhour * 1000 + self.bfinishminute
          myTime = theHour* 1000 + theMinute
          if myTime >= bStart and myTime < bFinish
            returnValue = true
          end
      end
      return returnValue

    end

    def pairOptions

        self.clinicdate == nil ? thisClinicdate = Date.today : thisClinicdate=self.clinicdate
        if self.vaxtype == "Covax"
            Clinic.where("template = ? and clinicdate > ? and clinicdate < ? and vaxtype='Covax'",false,thisClinicdate + 11.weeks, thisClinicdate + 13.weeks).all.collect { |c| [c.clinicdate.strftime('%d-%m-%Y') + "  (" + weeksBetween(c.clinicdate,thisClinicdate) + ")", c.id] }
            #Clinic.where(template: false).all.collect { |c| [c.clinicdate.strftime('%y-%m-%d'), c.id] }
        else
            Clinic.where("template = ? and clinicdate > ? and clinicdate < ? and vaxtype='CovaxP'",false,thisClinicdate + 3.weeks - 2.days, thisClinicdate + 5.weeks + 1.day).all.collect { |c| [c.clinicdate.strftime('%d-%m-%Y') + "  (" + weeksBetween(c.clinicdate,thisClinicdate) + ")", c.id] }
  
        end
    end

    def weeksBetween (date1,date2)
        dB = (date1 - date2).to_i
        wB = dB/7
        dayB=dB - (wB*7)
        return wB.to_s + "w" + dayB.to_s + "d"

    end

    def self.removePair(gc)
        aClinics = Clinic.where(pair1: gc).all
        aClinics.each do |c|
            c.update(pair1: nil)
        end
        aClinics = Clinic.where(pair2: gc).all
        aClinics.each do |c|
            c.update(pair2: nil)
        end


    end

    def  makePair
            self.vaxtype == "Covax" ? noWeeks=12 : noWeeks=3
            theMess = ""
            if self.pair1 !=nil and self.pair2 != nil 
               theMess = " New pair not created as pair already selected"
            elsif Clinic.where(clinicdate: self.clinicdate + noWeeks.weeks, vaxtype: self.vaxtype).first
              theMess = " New pair not created as clinic already existed on " + (self.clinicdate + noWeeks.weeks).strftime("%d-%m-%Y")
            else
              @clinic2=self.dup
              @clinic2.clinicdate = self.clinicdate + noWeeks.weeks
              @clinic2.pair1 = nil
              @clinic2.pair2 = nil
              @clinic2.live = false
              @clinic2.save
              self.update(pair1: @clinic2.id)
              theMess = ' Hidden Paired Clinic also created for ' + @clinic2.clinicdate.strftime("%d-%m-%Y")
            end
            return theMess

    end

    def Clinic.findTime(clinic_id)
        nextAppt=nil
        clinic= Clinic.find(clinic_id)
        clinic.groups.each do |group |
            unless clinic.isBreak?(group.starthour,group.startminute)
                  if group.vacancies > 0 
                        nextAppt=[group.starthour,group.startminute]
                        return nextAppt
                        break
                  end
            end
        end
        return nextAppt



    end


      








end
