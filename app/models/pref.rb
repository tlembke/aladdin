class Pref < ActiveRecord::Base





  def self.list
    {
      :clinic=>{:name=>'Clinic',:default=>'Acme CLinic'},
      :phone=>{:name=>'Telephone',:default=>'02 66280505'},
      :address=>{:name=>'Address',:default=>'61 Main St'},
      :suburb=>{:name=>'Suburb',:default=>'Alstonville'},
      :postcode=>{:name=>'Postcode',:default=>'9994'},
      :active=>{:name=>'Active',:default => "true"},
      :checkup=>{:name=>'Checkup Up Term',:default => "General Chec"},
      :urgent=>{:name=>'Urgent',:default => "Ring us for all urgent appointments"},
      :aladdinuser=>{:name=>'Aladdin User',:default => "Aladdin User"},
      :aladdinpassword=>{:name=>'Aladdin Password',:default => "password"},
      :websender=>{:name=>'Web Sender',:default => "Alstonville Clinic"},
      :webpassword=>{:name=>'Web Password',:default => "password"},
      :faxusername=>{:name=>'Fax Username',:default => "tlembke"},
      :faxpassword=>{:name=>'Fax Password',:default => "password"},
      :faxfolder=>{:name=>'Fax Folder',:default => "/Volumes/Fax"},
      :faxprocessedfolder=>{:name=>'Fax Processed Folder',:default => "/Volumes/Fax/processed"},
      :faxsend=>{:name=>'Fax Send',:default => "true"},
      :vacants=>{:name=>'Allow vacants',:default => "true"}
    }
  end

  def self.method_missing(method,val=nil)

	    if self.list.has_key? method
	      thisPref=Pref.where(name: method.to_s).first
	      default = self.list[method][:default]

	      if thisPref.nil?
	        return default
	      else
	        if default.kind_of? Integer
	          return thisPref.value.to_i
	        else
	          return thisPref.value
	        end
	      end
	    else
	    	
	      return nil
	    end
  end

  def self.get_id(name)
  	if thisPref=Pref.where(name: name).first
  		return thisPref.id
  	else
  		return 0
	end
  end
  
  
  def self.update_attributes(newdict)
    errors = {}
    newdict.each_pair do |key,val|
      key = key.to_sym
      if self.list.has_key? key
        errors[key] = self.set(key, val)
      end
    end
    return errors
  end
  
  def self.set(config,val)
    default = self.list[config][:default]
    logger.debug("config: %p val: %p" % [config,val])
    if default == true or default == false
      if val==true or val=="1" or val=="TRUE"
        val = true
        nval = "TRUE"
      else
        val = false
        nval = "FALSE"
      end
    elsif default.kind_of? Integer
      nval = val.to_s
      return "Must be valid integer" unless /[0-9\-\+]+/ =~ nval
    elsif default == 'localhost'
      return "Must be valid hostname" unless /[a-zA-Z\.\-_]+/ =~ val
      nval = val.to_s
    else
      nval = val.to_s
    end
    thisPref = Pref.find_by_name(config.to_s)
    if thisPref.nil? 
      Pref.new({:name=>config.to_s,:value=>nval}).save! unless val == default
    elsif thisPref.value != nval
      thisPref.value = nval
      thisPref.save!
    end
    return nil
  end

  def self.decrypt_password(password)
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.bickles_base)
        password = crypt.decrypt_and_verify(password) 
  end

end

