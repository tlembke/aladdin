json.array!(@measures) do |measure|
  json.extract! measure, :id, :name, :abbreviation, :description, :units, :target, :operator, :places, :local, :scale
  json.url measure_url(measure, format: :json)
end
