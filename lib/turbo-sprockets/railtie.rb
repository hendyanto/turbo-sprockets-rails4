module TurboSprockets
  class Railtie < ::Rails::Railtie
    initializer 'turbo-sprockets' do
      unless Sprockets::Manifest.method_defined?(:compile_with_parallelism)
        Sprockets::Manifest.class_eval do
          def compile_with_parallelism(*args)
            if ::TurboSprockets.configuration.precompile_in_parallel?
              ::TurboSprockets::ParallelCompiler.new(self).compile(*args)
            else
              compile_without_parallelism
            end
          end

          alias_method_chain :compile, :parallelism
        end
      end
    end

    config.after_initialize do
      if ::TurboSprockets.configuration.preload_in_parallel?
        ::TurboSprockets::AssetPreloader.preload!
        ActiveRecord::Base.connection.reconnect!
      end
    end
  end
end
