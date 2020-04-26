json.extract! consult, :id, :provider_id, :patient_id, :consultdate, :mbs, :type, :notes, :billed, :complete, :created_at, :updated_at
json.url consult_url(consult, format: :json)
