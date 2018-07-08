module RegistersHelper

	def displayCell(patient,header)
		@cell = Cell.where(patient_id: patient, header_id: header.id).first

		unless @cell
			# cell has no value so needs to be created.
			@cell = Cell.create(patient_id: patient, header_id: header.id, value: "", date: nil, note: "" )
		end

		value=@cell.display
		return_text = value


		if header.special
			if header.name  == "name"
				return_text = ActionController::Base.helpers.link_to @cell.value, Rails.application.routes.url_helpers.patient_path(patient)
			end


		elsif
			if header.code == "cb"
				return_text = check_box_tag 'cell', @cell.id, @cell.value=="1", data: {
	        remote: true, url: toggle_cell_path(@cell), method: "POST" }
			elsif header.code =="string" or header.code=="note"
				return_text = "<a href='#' id='editable_cell_value_" + @cell.id.to_s + "' data-defaultValue='Add new paragraph' data-type='textarea' data-pk='1' data-resource='cell' data-name='value' data-emptytext= 'Notes' data-url='/cells/" + @cell.id.to_s +  "' data-placeholder='Your notes here...' data-original-title='Enter notes' class='editable'>" + textarea_format(@cell.value)+ "</a>"

			end
		end
		return return_text.html_safe
	end

	def sort_link2(header)
	    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
	    icon = sort_direction == "asc" ? "glyphicon glyphicon-chevron-up" : "glyphicon glyphicon-chevron-down"
	    icon = column == sort_column ? icon : ""
	    link_to "#{header.name} <span class='#{icon}'></span>".html_safe, {header: header.id, direction: direction}
  	end

  	 def sort_link(header, title = nil)
  	 	column=header.name
	    title ||= (@model_class ? @model_class.human_attribute_name(column) : column.titleize)
	    direction = header.id == sort_column && sort_direction == "asc" ? "desc" : "asc"
	   icon = sort_direction == "asc" ? "glyphicon glyphicon-sort-by-attributes" : "glyphicon glyphicon-sort-by-attributes-alt"
	   # icon = sort_direction == "asc" ? "glyphicon glyphicon-chevron-up" : "glyphicon glyphicon-chevron-down"
	   icon = header.id == sort_column ? icon : ""

	    link_title = sort_direction == "asc" ? "Sort table in ascending order" : "Sort table in descending order"
	    link_to "<span title=\"#{h link_title}\">#{h title} <span class=\"#{icon}\"></span></span>".html_safe, {header: header.id, direction: direction}
  end


  def sort_column
    sort_header =Header.where(register_id: @register.id).order(sort: "asc").first
    if params[:header]
      sort_column= params[:header]
    else
      sort_h =Header.where(register_id: @register.id).order(sort: "asc").first
      sort_column=sort_h.id
    end
     return sort_column.to_i


  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end



