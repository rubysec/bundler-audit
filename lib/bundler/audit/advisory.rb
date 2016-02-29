#
# Copyright (c) 2013-2016 Hal Brodigan (postmodern.mod3 at gmail.com)
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
    class Advisory < Struct.new(:path,
                                :id,
                                :url,
                                :title,
                                :date,
                                :description,
                                :cvss_v2,
                                :cve,
                                :osvdb,
                                :unaffected_versions,
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
        id   = File.basename(path).chomp('.yml')
        data = YAML.load_file(path)

        unless data.kind_of?(Hash)
          raise("advisory data in #{path.dump} was not a Hash")
        end

        parse_versions = lambda { |versions|
          Array(versions).map do |version|
            Gem::Requirement.new(*version.split(', '))
          end
        }

        return new(
          path,
          id,
          data['url'],
          data['title'],
          data['date'],
          data['description'],
          data['cvss_v2'],
          data['cve'],
          data['osvdb'],
          parse_versions[data['unaffected_versions']],
          parse_versions[data['patched_versions']]
        )
      end

      #
      # The CVE identifier.
      #
      # @return [String, nil]
      #
      def cve_id
        "CVE-#{cve}" if cve
      end

      #
      # The OSVDB identifier.
      #
      # @return [String, nil]
      #
      def osvdb_id
        "OSVDB-#{osvdb}" if osvdb
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
      # Checks whether the version is not affected by the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#unaffected_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is not affected by the advisory.
      #
      # @since 0.2.0
      #
      def unaffected?(version)
        unaffected_versions.any? do |unaffected_version|
          unaffected_version === version
        end
      end

      #
      # Checks whether the version is patched against the advisory.
      #
      # @param [Gem::Version] version
      #   The version to compare against {#patched_versions}.
      #
      # @return [Boolean]
      #   Specifies whether the version is patched against the advisory.
      #
      # @since 0.2.0
      #
      def patched?(version)
        patched_versions.any? do |patched_version|
          patched_version === version
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
        !patched?(version) && !unaffected?(version)
      end

      alias to_s id

    end
  end
end
