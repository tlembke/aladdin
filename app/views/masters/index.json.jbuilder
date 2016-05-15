json.array!(@masters) do |master|
  json.extract! master, :id, :name
  json.url master_url(master, format: :json)
end
