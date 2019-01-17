module Bundler
  module Audit
    module Presenter
      class Base
        attr_reader :options
        attr_reader :shell

        def initialize(shell, options)
          @shell = shell
          @options = options
          @warnings = []
          @advisory_bundles = []
        end

        def push_warning(message)
          @warnings.push(message)
        end

        def push_advisory(advisory)
          @advisory_bundles.push(advisory)
        end

        def print_report
          raise RuntimeError, "Not Implemented"
        end

        def exit_code
          problematic? ? 1 : 0
        end

        protected

        def problematic?
          @warnings.any? || @advisory_bundles.any?
        end
      end
    end
  end
end
