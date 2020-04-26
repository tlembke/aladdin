json.extract! document, :id, :name, :description, :patient_id, :type, :parent, :texttype, :content, :created_at, :updated_at
json.url document_url(document, format: :json)
