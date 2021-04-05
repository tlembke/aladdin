class Clinic < ActiveRecord::Base
	has_many :bookers, -> { order 'bookhour, bookminute' }
	has_many :groups

	#attr_accessor :groups

	def self.initialize
		@groups = groups

	end

	def self.findAllGroups(vaxType="Fluvax")

		@allClinics = Clinic.where("vaxtype = ? and clinicdate >= ? and live = ?",vaxType,Date.today,true).all

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


end
