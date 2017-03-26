json.array!(@prefs) do |pref|
  json.extract! pref, :id, :name, :value
  json.url pref_url(pref, format: :json)
end
