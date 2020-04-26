module DocumentsHelper

	def actionsplans_for_select
		debugger
  		Document.all.collect { |m| [m.name, m.id] }
	end
end
