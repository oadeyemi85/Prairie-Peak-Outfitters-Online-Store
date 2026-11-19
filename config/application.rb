require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module PrairiePeak
  class Application < Rails::Application
    config.load_defaults 7.1
    config.time_zone = "Central Time (US & Canada)"
    config.active_storage.variant_processor = :vips
  end
end
