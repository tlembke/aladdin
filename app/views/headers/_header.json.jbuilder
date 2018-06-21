json.extract! header, :id, :name, :code, :special, :created_at, :updated_at
json.url header_url(header, format: :json)
