module ResultsHelper

	def pit_convert(pit)
		
			pitArray=[["\\R\\SBLD\\R\\","<b>"],["\\R\\EBLD\\R\\","</b>"],["\\H\\","<b>"],["\\N\\","</b>"],["\\R\\FG04\\R\\","<font color='red'>"],["\\R\\FG99\\R\\","</font>"],["~FG04~","<font color='red'>"],["~FG99~","</font>"]]
			pitArray.each do |pair|
				pit.gsub! pair[0],pair[1]
			end
			return pit
	end
end
