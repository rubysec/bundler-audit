require 'thor'

module Bundler
  module Audit
    class CLI < ::Thor
      module Printers
        class PrinterNotFound < RuntimeError
        end

        # Directory where printer modules are loaded from.
        DIR = 'bundler/audit/cli/printers'

        @registry = {}

        #
        # Registers a printer with the given format name.
        #
        # @param [Symbol, String] name
        #
        # @param [Module#print_results] printer
        #   The printer object.
        #
        # @raise [NotImplementedError]
        #   The printer object does not respond to `#call`.
        #
        # @api public
        #
        def self.register(name,printer)
          unless printer.instance_methods.include?(:print_results)
            raise(NotImplementedError,"#{printer.inspect} does not define #print_results")
          end

          @registry[name.to_sym] = printer
        end

        #
        # Retrieves the format by name.
        #
        # @param [String, Symbol] name
        #
        # @return [Module#print_results, nil]
        #   The printer registered with the given name or `nil`.
        #
        def self.[](name)
          @registry[name.to_sym]
        end

        #
        # Loads the printer with the given name.
        #
        # @param [#to_s] name
        #
        # @return [Module#print_results]
        #
        # @raise [PrinterNotFound]
        #   No printer exists with that given name.
        #
        def self.load(name)
          name = name.to_s

          begin
            require File.join(DIR,File.basename(name))
          rescue LoadError
            raise(PrinterNotFound,"could not load printer #{name.inspect}")
          end

          return self[name] || \
            raise(PrinterNotFound,"unknown printer #{name.inspect}")
        end
      end
    end
  end
end

require 'bundler/audit/cli/printers/text'
