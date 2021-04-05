class ApptLog
  def self.info(message=nil)
    @appt_log ||= Logger.new("#{Rails.root}/log/appt.log")
    @appt_log.info(message) unless message.nil?
  end
    def self.error(message=nil)
    @appt_log ||= Logger.new("#{Rails.root}/log/appt.log")
    @appt_log.error(message) unless message.nil?
  end
end
