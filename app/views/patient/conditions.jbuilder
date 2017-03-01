
  json.resourceType "bundle"  
  json.type "transaction"
  json.total  @current_problems.count
  json.entry do
  i=0
  json.array!(@current_problems) do | problem |
      i+=1    
      json.request do
        json.method "POST"
        json.url "/Condition"
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
          json.resourceType "Condition"
          json.id i.to_s
          json.code do
            json.coding do
              json.system "http://hl7.org/fhir/sid/icpc-2"
              json.code problem['ICPCCODE']
              json.display problem['PROBLEM']
            end
          end #end code
          json.category do
              json.coding do
                json.system "http://snomed.info/sct"
                json.code "439401001"
                json.display "Diagnosis"
              end
          end #end category
      
          json.clinicalStatus "active"
          if problem['DIAGNOSISDATE']
            json.onsetDateTime problem['DIAGNOSISDATE']
          end

      	  json.patient do
      	   json.reference "Patient/"+@patient.ihi
          end
      end # end resource
    
    end #end problem
  end #end entry
