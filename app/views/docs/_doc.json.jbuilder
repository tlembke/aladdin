json.extract! doc, :id, :name, :filename, :thumbnail, :description, :cat, :created_at, :updated_at
json.url doc_url(doc, format: :json)
