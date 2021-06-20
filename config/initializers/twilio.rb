Twilio.configure do |config|
  config.account_sid = Pref.decrypt_password(Pref.TWILIO_ACCOUNT_SID)
  config.auth_token  = Pref.decrypt_password(Pref.TWILIO_AUTH_TOKEN)
end
