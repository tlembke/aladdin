json.extract! clinic, :id, :clinicdate, :starthour, :startminute, :finishhour, :finishminute, :perhour, :vaxtype, :venue, :template, :age, :ATSIage, :chronic, :chronicage, :message, :created_at, :updated_at
json.url clinic_url(clinic, format: :json)
