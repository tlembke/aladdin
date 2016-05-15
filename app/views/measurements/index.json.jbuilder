json.array!(@measurements) do |measurement|
  json.extract! measurement, :id, :patient_id, :measure_id, :value, :measuredate
  json.url measurement_url(measurement, format: :json)
end
