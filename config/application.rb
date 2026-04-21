require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Haby
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # タイムゾーン・ロケール
    config.time_zone = "Asia/Tokyo"
    config.i18n.default_locale = :ja
    config.i18n.available_locales = %i[ja en]
    # config.eager_load_paths << Rails.root.join("extras")
    # 不要なファイルを生成しない
    config.generators do |g|
      g.assets  false  # CSS/JS 生成しない
      g.helper  false  # helper 生成しない
      g.jbuilder false # jbuilder 生成しない
    end
  end
end
