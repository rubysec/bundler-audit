#
# Copyright (c) 2013-2015 Hal Brodigan (postmodern.mod3 at gmail.com)
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
        id  = File.basename(path).chomp('.yml')
        doc = YAML.parse(File.new(path))

        unless doc.root.kind_of?(YAML::Nodes::Mapping)
          raise("advisory data in #{path.dump} was not a Hash")
        end

        hash = Hash[doc.root.children.each_slice(2).map { |key,value|
          [key.value, value]
        }]

        unless hash.has_key?('url')
          raise("advisory data in #{path.dump} is missing a url")
        end
        
        unless hash.has_key?('title')
          raise("advisory data in #{path.dump} is missing a title")
        end
        
        unless hash.has_key?('description')
          raise("advisory data in #{path.dump} is missing a description")
        end

        unless hash.has_key?('patched_versions')
          raise("advisory data in #{path.dump} is missing patched_versions")
        end

        unless hash['url'].is_a?(YAML::Nodes::Scalar)
          raise("url in #{path.dump} is missing or not a String")
        end

        unless hash['title'].is_a?(YAML::Nodes::Scalar)
          raise("title in #{path.dump} is missing or not a String")
        end

        unless hash['description'].is_a?(YAML::Nodes::Scalar)
          raise("description in #{path.dump} is not a String")
        end

        if hash.has_key?('cve')
          unless hash['cve'].is_a?(YAML::Nodes::Scalar)
            raise("cve in #{path.dump} is not a String")
          end
        end

        if hash.has_key?('osvdb')
          unless hash['osvdb'].is_a?(YAML::Nodes::Scalar)
            raise("osvdb in #{path.dump} is not a String")
          end
        end

        if hash.has_key?('unaffected_versions')
          unless hash['unaffected_versions'].is_a?(YAML::Nodes::Sequence)
            raise("unaffected_versions in #{path.dump} is not an Array")
          end

          unless hash['unaffected_versions'].children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
            raise("unaffected_versions in #{path.dump} contains a non-String")
          end
        end

        unless hash['patched_versions'].is_a?(YAML::Nodes::Sequence)
          raise("patched_versions in #{path.dump} is not an Array")
        end
          
        unless hash['patched_versions'].children.all? { |node| node.is_a?(YAML::Nodes::Scalar) }
          raise("patched_versions in #{path.dump} contains a non-String")
        end

        url         = hash['url'].value
        title       = hash['title'].value
        description = hash['description'].value
        cvss_v2     = if hash.has_key?('cvss_v2')
                        unless hash['cvss_v2'].value.empty?
                          Float(hash['cvss_v2'].value)
                        end
                      end
        cve         = if hash.hash_key?('cve')
                        unless hash['cve'].value.empty?
                          hash['cve'].value
                        end
                      end
        osvdb       = if hash.has_key?('osvdb')
                        unless hash['osvdb'].value.empty?
                          hash['osvdb'].value
                        end
                      end

        parse_versions = lambda { |versions|
          versions.children.map do |version|
            Gem::Requirement.new(*version.value.split(', '))
          end
        }

        unaffected_versions = if hash.has_key?('unaffected_versions')
                                parse_versions[hash['patched_versions']]
                              else
                                []
                              end
        patched_versions = parse_versions[hash['patched_versions']]

        return new(
          path,
          id,
          url,
          title,
          description,
          cvss_v2,
          cve,
          osvdb,
          unaffected_versions,
          patched_versions
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
