
  json.resourceType "Patient"

  json.identifier do
    json.value @patient.ihi
    json.system "http://ns.electronichealth.net.au/id/hi/ihi"
  end
  
  json.name do
  	json.family @patient.surname
  	json.given  @patient.firstname
  end
  json.gender @patient.sex =="M" ? "male" : "female"
  json.birthDate @patient.dob.strftime("%Y-%m-%d")
  json.address do
  	json.line @patient.addressline1
  	json.city @patient.suburb
  end
