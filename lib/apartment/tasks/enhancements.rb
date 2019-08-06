# Require this file to append Apartment rake tasks to ActiveRecord db rake tasks
# Enabled by default in the initializer

module Apartment
  class RakeTaskEnhancer
    
    TASKS = %w(db:migrate db:rollback db:migrate:up db:migrate:down db:migrate:redo db:seed)
    
    # This is a bit convoluted, but helps solve problems when using Apartment within an engine
    # See spec/integration/use_within_an_engine.rb
    
    class << self
      def enhance!
        TASKS.each do |name|
          task = Rake::Task[name]
          task.enhance do
            if should_enhance?(name)
              enhance_task(task)
            end
          end
        end
      end
    
      def should_enhance?(name)
        return true if name == 'db:seed' and Apartment.seed_after_create
        Apartment.db_migrate_tenants
      end
    
      def enhance_task(task)
        Rake::Task[task.name.sub(/db:/, 'apartment:')].invoke
      end
    end
    
  end
end

Apartment::RakeTaskEnhancer.enhance!
