require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false
  config.assets.css_compressor = nil
  config.active_storage.service = ENV["AWS_BUCKET"].present? ? :amazon : :local
  config.force_ssl = ENV["FORCE_SSL"] == "true"
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.logger = ActiveSupport::Logger.new($stdout) if ENV["RAILS_LOG_TO_STDOUT"].present?
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
