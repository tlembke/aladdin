class FaxLog
  def self.info(message=nil)
    @fax_log ||= Logger.new("#{Rails.root}/log/fax.log")
    @fax_log.info(message) unless message.nil?
  end
end