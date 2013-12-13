module Goodsheet

  module Common
    
    module InstanceMethods
      def init(options, &block)
        @settings = Goodsheet::ReadingSettings.new(options)
        row_class = Goodsheet::Row.extend_with(block)
        read_result = Goodsheet::ReadResult.new(row_class.attributes, @settings.max_errors, options[:collector]||:a_arr)
        errors = Goodsheet::ValidationErrors.new(@settings.max_errors)
        [row_class, read_result, errors]
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end