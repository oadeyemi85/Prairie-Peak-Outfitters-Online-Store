require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.cache_store = :null_store
  config.active_storage.service = ENV["AWS_BUCKET"].present? ? :amazon : :local
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.quiet = true
  config.action_controller.raise_on_missing_callback_actions = true
end
