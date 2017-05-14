module GoalsHelper
	def autoload_select
		autoload= []
		theArray= [['None',''],['General', 'general'], ['Diabetes', 'diabetes'],['IHD', 'ihd'],['Hypertension', 'hypertension'],['Hypothyroidism', 'hypothyroid'],['COPD', 'copd'],['Asthma', 'asthma'],['CKD', 'ckd'],['Prostate Cancer', 'prostateca']]
		
      	theArray.each do |x| 
        	autoload << {value: x[1] , text: x[0] }
      	end

      	return autoload
	end
end
