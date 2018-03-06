require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Formats
        class FormatNotFound < RuntimeError
        end

        # Directory where format modules are loaded from.
        DIR = 'bundler/audit/cli/formats'

        @registry = {}

        #
        # Registers a format with the given format name.
        #
        # @param [Symbol, String] name
        #
        # @param [Module#print_results] format
        #   The format object.
        #
        # @raise [NotImplementedError]
        #   The format object does not respond to `#call`.
        #
        # @api public
        #
        def self.register(name,format)
          unless format.instance_methods.include?(:print_report)
            raise(NotImplementedError,"#{format.inspect} does not define #print_report")
          end

          @registry[name.to_sym] = format
        end

        #
        # Retrieves the format by name.
        #
        # @param [String, Symbol] name
        #
        # @return [Module#print_results, nil]
        #   The format registered with the given name or `nil`.
        #
        def self.[](name)
          @registry[name.to_sym]
        end

        #
        # Loads the format with the given name.
        #
        # @param [#to_s] name
        #
        # @return [Module#print_results]
        #
        # @raise [FormatNotFound]
        #   No format exists with that given name.
        #
        def self.load(name)
          name = name.to_s

          begin
            require File.join(DIR,File.basename(name))
          rescue LoadError
            raise(FormatNotFound,"could not load format #{name.inspect}")
          end

          return self[name] || \
            raise(FormatNotFound,"unknown format #{name.inspect}")
        end
      end
    end
  end
end

require 'bundler/audit/cli/formats/text'
