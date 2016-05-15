json.array!(@goals) do |goal|
  json.extract! goal, :id, :title, :description, :condition_id, :patient_id, :measure_id, :active, :parent
  json.url goal_url(goal, format: :json)
end
