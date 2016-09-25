
  json.resourceType "Patient"
  json.identifier @patient.ihi
  json.name do
  	json.family @patient.surname
  	json.given  @patient.firstname
  end
  json.birthDate @patient.dob.strftime("%y-%m-%d")
  json.address do
  	json.line @patient.addressline1
  	json.city @patient.suburb
  end
