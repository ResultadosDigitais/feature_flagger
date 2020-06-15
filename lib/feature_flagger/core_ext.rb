# frozen_string_literal: true

begin
  require 'active_support/core_ext/string/inflections'
rescue LoadError
  unless ''.respond_to?(:constantize)
    class String
      def constantize
        names = split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end
    end
  end
end
