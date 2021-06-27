system(Rails.root.join('start_sidekiq.sh').to_s)

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

schedule_file = "config/schedule.yml"

if File.exists?(schedule_file)
	Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
