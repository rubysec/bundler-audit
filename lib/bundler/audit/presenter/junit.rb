require 'erb'

module Bundler
  module Audit
    module Presenter
      class Junit < Base
        def print_report
          puts ERB.new(template_string, nil, '-').result(binding)
        end

        protected

        def advisory_ref(advisory)
          if advisory.cve
            "CVE-#{advisory.cve}"
          elsif advisory.osvdb
            advisory.osvdb
          end
        end

        def advisory_criticality(advisory)
          case advisory.criticality
          when :low    then "Low"
          when :medium then "Medium"
          when :high   then "High"
          else              "Unknown"
          end
        end

        def advisory_solution(advisory)
          unless advisory.patched_versions.empty?
            "upgrade to #{advisory.patched_versions.join(', ')}"
          else
            "remove or disable this gem until a patch is available!"
          end
        end

        def bundle_title(bundle)
          "#{advisory_criticality(bundle.advisory).upcase} #{bundle.gem.name}(#{bundle.gem.version}) #{bundle.advisory.title}"
        end

        def template_string
          <<-HERE.strip
<?xml version="1.0" encoding="UTF-8" ?>
<testsuites id="<%= Time.now.to_i %>" name="Bundle Audit" tests="225" failures="1262">
  <testsuite id="Gemfile" name="Ruby Gemfile" failures="<%= @advisory_bundles.size %>">
    <%- @advisory_bundles.each do |bundle| -%>
    <testcase id="<%= bundle.gem.name %>" name="<%= bundle_title(bundle) %>">
      <failure message="<%= bundle.advisory.title %>" type="<%= bundle.advisory.criticality %>">
Name: <%= bundle.gem.name %>
Version: <%= bundle.gem.version %>
Advisory: <%= advisory_ref(bundle.advisory) %>
Criticality: <%= advisory_criticality(bundle.advisory) %>
URL: <%= bundle.advisory.url %>
Title: <%= bundle.advisory.title %>
Solution: <%= advisory_solution(bundle.advisory) %>
      </failure>
    </testcase>
    <%- end -%>
  </testsuite>
</testsuites>
          HERE
        end
      end
    end
  end
end
