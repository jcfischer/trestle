module Trestle
  module Adapters
    extend ActiveSupport::Autoload

    require_relative "adapters/adapter"

    autoload :ActiveRecordAdapter
    autoload :DraperAdapter
    autoload :SequelAdapter
    autoload :ActiveResourceAdapter

    # Creates a new Adapter class with the given modules mixed in
    def self.compose(*modules)
      Class.new(Adapter) do
        modules.each { |mod| include(mod) }
      end
    end
  end
end
