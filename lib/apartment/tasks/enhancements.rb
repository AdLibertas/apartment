# Require this file to append Apartment rake tasks to ActiveRecord db rake tasks
# Enabled by default in the initializer

module Apartment
  class RakeTaskEnhancer
    
    TASKS = %w(db:migrate db:rollback db:migrate:up db:migrate:down db:migrate:redo)
    
    # This is a bit convoluted, but helps solve problems when using Apartment within an engine
    # See spec/integration/use_within_an_engine.rb
    
    class << self
      def enhance!
        TASKS.each do |name|
          task = Rake::Task[name]
          task.enhance [Rake::Task[task.name.sub(/db:/, 'apartment:')]]
        end
      end
    end
  end
end

Apartment::RakeTaskEnhancer.enhance!
