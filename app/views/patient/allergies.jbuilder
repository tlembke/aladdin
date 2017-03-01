  json.resourceType "bundle"  
  json.type "transaction"
  json.total  @allergies.count
  json.entry do

  json.array!(@allergies) do | allergy |

    
      json.request do
        json.method "POST"
        json.url "/AllergyIntolerance"
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
        json.resourceType "AllergyIntolerance"

        json.substance do
            json.coding do
              codes = []
              codes=[["http://what.goes.here.for.MIMS.ClassCode",allergy["CLASSCODE"]],["http://what.goes.here.for.MIMS.GenericCode",allergy["GENERICCODE"]]]
              json.array! codes do  |code|
                json.system code[0]
                json.code code[1].to_s
                json.display allergy["ALLERGY"]
              end
            end
            json.text allergy["ALLERGY"]

        end
        json.reaction do
          json.manifestation do
              json.text allergy["DETAIL"]
          end
        end
        json.patient do
         json.reference "Patient/"+@patient.ihi
        end
      



      end # end resource
    
    end #end medication
  end #end entry