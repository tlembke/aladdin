module RegistersHelper

	def displayCell(patient,header)
		@cell = Cell.where(patient_id: patient, header_id: header.id).first
		unless @cell
			# cell has no value so needs to be created.
			@cell = Cell.create(patient_id: patient, header_id: header.id, value: "", date: nil, note: "" )
		end

		value=@cell.display
		if header.code == "cb"
			return_text = check_box_tag 'cell', @cell.id, @cell.value=="1", data: {
        remote: true, url: toggle_cell_path(@cell), method: "POST" }
		elsif header.code =="string" and not header.special
			return_text = "<a href='#' id='editable_cell_value_" + @cell.id.to_s + "' data-defaultValue='Add new paragraph' data-type='textarea' data-pk='1' data-resource='cell' data-name='value' data-emptytext= 'Notes' data-url='/cells/" + @cell.id.to_s +  "' data-placeholder='Your notes here...' data-original-title='Enter notes' class='editable'>" + textarea_format(@cell.value)+ "</a>"
		else
			return_text = value
		end
		return return_text.html_safe
	end
end



