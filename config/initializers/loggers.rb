EventsWithoutDateLogger   = Logger.new("#{Rails.root}/log/without_dates.log")
FailedEventsLogger        = Logger.new("#{Rails.root}/log/failed_events.log")
WrongDatesLog             = Logger.new("#{Rails.root}/log/wrong_dates.log")
SlowImagesLog             = Logger.new("#{Rails.root}/log/slow_images.log")
LowMembersLog             = Logger.new("#{Rails.root}/log/low_members.log")

Browserlog.config.allowed_log_files << %w[failed_events low_members slow_images withot_dates wrong_dates]
Browserlog.config.allowed_log_files.flatten!
Browserlog.config.allow_production_logs = true