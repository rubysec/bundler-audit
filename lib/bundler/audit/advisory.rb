#
# Copyright (c) 2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# bundler-audit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bundler-audit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bundler-audit.  If not, see <http://www.gnu.org/licenses/>.
#

require 'yaml'

module Bundler
  module Audit
    class Advisory < Struct.new(:cve,
                                :url,
                                :title,
                                :description,
                                :cvss_v2,
                                :patched_versions)

      #
      # Loads the advisory from a YAML file.
      #
      # @param [String] path
      #   The path to the advisory YAML file.
      #
      # @return [Advisory]
      #
      # @api semipublic
      #
      def self.load(path)
        cve  = File.basename(path).chomp('.yml')
        data = YAML.load_file(path)

        unless data.kind_of?(Hash)
          raise("advisory data in #{path.dump} was not a Hash")
        end

        return new(
          cve,
          data['url'],
          data['title'],
          data['description'],
          data['cvss_v2'],
          Array(data['patched_versions']).map { |version|
            Gem::Requirement.new(*version.split(', '))
          }
        )
      end

      #
      # Determines how critical the vulnerability is.
      #
      # @return [:low, :medium, :high]
      #   The criticality of the vulnerability based on the CVSSv2 score.
      #
      def criticality
        case cvss_v2
        when 0.0..3.3  then :low
        when 3.3..6.6  then :medium
        when 6.6..10.0 then :high
        end
      end

      #
      # Checks whether the version is vulnerable to the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#patched_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is vulnerable to the advisory or not.
      #
      def vulnerable?(version)
        !patched_versions.any? do |patched_version|
          patched_version === version
        end
      end

      #
      # Converts the advisory to a String.
      #
      # @return [String]
      #   The CVE identifier.
      #
      def to_s
        "CVE-#{cve}"
      end

    end
  end
end
