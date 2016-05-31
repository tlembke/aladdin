json.array!(@phonetimes) do |phonetime|
  json.extract! phonetime, :id, :doctor_id, :message
  json.url phonetime_url(phonetime, format: :json)
end
