  json.resourceType "bundle"  
  json.type "transaction"
  json.total  @medications.count
  json.entry do

  json.array!(@medications) do | medication |

    
      json.request do
        json.method "POST"
        json.url "/MedicationOrder"
      end #end request
      json.resource do
        extension1s = [1]
        # array is required so need to do this artiifical process
        json.extension do
              json.array! extension1s do |extension1|
                json.url "http://fhir.hl7.org.nz/dstu2/StructureDefinition/ohAgent"
                json.extension do
                    extension2s = [1]
                    # array is required so need to do this artiifical process
                    json.array! extension2s do |extension2|
                      json.url "actorId"
                      json.valueIdentifier do
                          json.value @hpio
                      end
                    end
                end
              end

        end
        json.resourceType "MedicationOrder"
        json.dosageInstruction do
            json.text medication["DOSE"]+ " " + medication["FREQUENCY"] + " "
            json.additionalInstructions do
                json.text medication["INSTRUCTIONS"]
            end

        end
        json.dateWritten medication["CREATIONDATE"] ? medication["CREATIONDATE"].strftime("%Y-%m-%d") : ""
        json.status "active"
        json.patient do
         json.reference "Patient/"+@patient.ihi
        end
        json.prescriber do 
          json.reference "Unknown"
          json.display "Unknown"
        end 
        json.identifier do
              
          json.use "usual"
          json.system "http://oridashi.com.au/system/id/scriptnumber"
          json.value medication["ID"].to_s
        end


        codes =[["http://snomed.info/sct",medication["AMT"],medication["AMTName"]]]
        json.medicationCodeableConcept do
            json.coding do
              json.array! codes do |code|
                json.system code[0]
                json.code code[1]
                json.display code[2]
              end
            end
            json.text medication["MEDICATION"]
        end #end category
      



      end # end resource
    
    end #end medication
  end #end entry