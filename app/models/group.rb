class Group
  include ActiveModel::Model




  

  attr_accessor :id, :clinic_id, :starthour, :startminute, :bookers, :vacancies

  def initialize(clinic_id,starthour,startminute,bookers,vacancies)
  		@clinic_id = clinic_id
  		@starthour = starthour
  		@startminute = startminute
  		@bookers= bookers
  		@vacancies = vacancies
  end

  def self.all
    ObjectSpace.each_object(self).to_a
  end

  def self.count
    all.count
  end

end