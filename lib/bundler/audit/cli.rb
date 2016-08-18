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

require 'bundler/audit/scanner'
require 'bundler/audit/version'

require 'thor'
require 'bundler'
require 'bundler/vendored_thor'
require 'json'

module Bundler
  module Audit
    class CLI < ::Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :verbose, :type => :boolean, :aliases => '-v'
      method_option :ignore, :type => :array, :aliases => '-i'
      method_option :update, :type => :boolean, :aliases => '-u'
      method_option :output, :type => :string, :default => 'text', :aliases => '-o'

      @output = nil
      @vulnerable = false

      def check
        update if options[:update]

        scanner    = Scanner.new

        initialize_formatting

        scanner.scan(:ignore => options.ignore) do |result|
          @vulnerable = true
          data_output result
        end
  
        print_output
        exit 1 if @vulnerable
      end

      desc 'update', 'Updates the ruby-advisory-db'
      def update
        say "Updating ruby-advisory-db ..."

        case Database.update!
        when true
          say "Updated ruby-advisory-db", :green
        when false
          say "Failed updating ruby-advisory-db!", :red
          exit 1
        when nil
          say "Skipping update", :yellow
        end

        puts "ruby-advisory-db: #{Database.new.size} advisories"
      end

      desc 'version', 'Prints the bundler-audit version'
      def version
        database = Database.new

        puts "#{File.basename($0)} #{VERSION} (advisories: #{database.size})"
      end

      protected
      
      def initialize_formatting
        case options[:output]
          when 'json'
            @output = {vulnerable: false, insecure_sources: [], advisories: []}
          when 'text'
            @output = []
        end
      end

      def print_output
        case options[:output]
          when 'json'
            puts @output.to_json
          when 'text'
            @output << (@vulnerable ? [:say, 'Vulnerabilities found!', :red] : [:say, 'No vulnerabilities found', :green])
            @output.each do |msg|
              self.send msg[0], msg[1], msg[2]
            end
        end
      end 

      def data_output(result)
        case options[:output]
          when 'text'
            case result
              when Scanner::InsecureSource
                @output << [:say, "Insecure Source URI found: #{result.source}", :yellow]
              when Scanner::UnpatchedGem   
                gem = result.gem
                advisory = result.advisory
                @output << [:say, "Name: ", :red]
                @output << [:say, gem.name, nil]

                @output << [:say, "Version: ", :red]
                @output << [:say, gem.version, nil]

                @output << [:say, "Advisory: ", :red]
                
                @output << (advisory.cve ? [:say, "CVE-#{advisory.cve}", nil] : [:say, advisory.osvdb, nil])

                @output << [:say, "Criticality: ", :red]
           
                case advisory.criticality
                when :low    then @output << [:say, "Low", nil]
                when :medium then @output << [:say, "Medium", :yellow]
                when :high   then @output << [:say, "High", [:red, :bold]]
                else              @output << [:say, "Unknown", nil]
                end

                @output << [:say, "URL: ", :red]
                @output << [:say, advisory.url, nil]

                if options.verbose?
                  @output << [:say, "Description:", :red]
                  @output << [:say, '', nil]

                  @output << [:print_wrapped, advisory.description, [:indent => 2]]
                  @output << [:say, '', nil]
                else

                  @output << [:say, "Title: ", :red]
                  @output << [:say, advisory.title, nil]
                end

                unless advisory.patched_versions.empty?
                  @output << [:say, "Solution: upgrade to ", :red]
                  @output << [:say, advisory.patched_versions.join(', '), nil]
                else
                  @output << [:say, "Solution: ", :red]
                  @output << [:say, "remove or disable this gem until a patch is available!", [:red, :bold]]
                end
                  @output << [:say, '', nil]
            end
          when 'json'
            case result
              when Scanner::InsecureSource
                @output[:insecure_sources] << {url: result.source}
              when Scanner::UnpatchedGem
                gem = result.gem
                advisory = result.advisory
                advisory_item = {
                  name: gem.name,
                  version: gem.version,
                  cve: advisory.cve ? advisory.cve : '',
                  osvdb: advisory.osvdb ? advisory.osvdb : '',
                  criticality: advisory.criticality ? advisory.criticality.to_s.capitalize : 'Unknown',
                  url: advisory.url,
                  description: options.verbose? ? advisory.description : '',
                  solution: advisory.patched_versions.empty? ? 'remove or disable this gem until a patch is available!' : "Upgrade to: #{advisory.patched_versions.join(', ')}"
                }
                @output[:vulnerable] = true
                @output[:advisories] << advisory_item
            end
        end
      end

      def say(message="", color=nil)
        color = nil unless $stdout.tty?
        super(message.to_s, color)
      end

    end
  end
end
