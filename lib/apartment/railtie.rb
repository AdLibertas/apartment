require 'rails'
require 'apartment/tenant'
require 'apartment/resolvers/database'

module Apartment
  class Railtie < Rails::Railtie

    def self.prep
      Apartment.configure do |config|
        config.excluded_models = []
        config.force_reconnect_on_switch = false
        config.tenant_names = []
        config.seed_after_create = false
        config.tenant_resolver = Apartment::Resolvers::Database
      end

      ActiveRecord::Migrator.migrations_paths = Rails.application.paths['db/migrate'].to_a
    end

    #
    #   Set up our default config options
    #   Do this before the app initializers run so we don't override custom settings
    #
    config.before_initialize{ prep }

    #   Hook into ActionDispatch::Reloader to ensure Apartment is properly initialized
    #   Note that this doens't entirely work as expected in Development, because this is called before classes are reloaded
    #   See the middleware/console declarations below to help with this. Hope to fix that soon.
    #
    config.to_prepare do
      begin
        unless ARGV.any? { |arg| arg =~ /\Aassets:(?:precompile|clean)\z/ }
          Apartment.connection_class.connection_pool.with_connection do
            Apartment::Tenant.init
          end
        end
      rescue ::ActiveRecord::NoDatabaseError => e
        puts e.message
      end
    end

    #
    #   Ensure rake tasks are loaded
    #
    rake_tasks do
      load 'tasks/apartment.rake'
      require 'apartment/tasks/enhancements'
    end

    #
    #   The following initializers are a workaround to the fact that I can't properly hook into the rails reloader
    #   Note this is technically valid for any environment where cache_classes is false, for us, it's just development
    #
    if Rails.env.development?
      # Overrides reload! to also call Apartment::Tenant.init as well so that the reloaded classes have the proper table_names
      console do
        require 'apartment/console'
      end
    end
  end
end
