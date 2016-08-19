require 'bundler'
require 'json'

module Bundler
  module Audit
    class Formatter
      attr_accessor :vulnerable
      
      #
      # Initializes a formatter
      # 
      # @param [String] format
      # @param [Boolean] verbose
      # @param [Bundler::Audit::CLI] CLI instance
      #
      def initialize(format, verbose, cli)
        @format = format
        @cli = cli
        @vulnerable = false
        @verbose = verbose

        case format
          when 'text'
            @output = []
          when 'json'
            @output = {vulnerabe: @vulnerable, insecure_sources: [], advisories: []}
        end
      end
      
      #
      # Takes scanner result and updates output buffer
      #
      # @param [Scanner] Scan result block
      #
      def update(result)
        case @format
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

                if @verbose
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
                  description: @verbose ? advisory.description : '',
                  solution: advisory.patched_versions.empty? ? 'remove or disable this gem until a patch is available!' : "Upgrade to: #{advisory.patched_versions.join(', ')}"
                }
                @output[:vulnerable] = true
                @output[:advisories] << advisory_item
            end
          end
        end
        
        #
        # returns output of scan results in requested format
        # 
        # @return [String]
        # 
        def output
          case @format
            when 'json'
              puts @output.to_json
            when 'text'
              @output << (@vulnerable ? [:say, 'Vulnerabilities found!', :red] : [:say, 'No vulnerabilities found', :green])
              @output.each do |msg|
                @cli.send msg[0], msg[1], msg[2]
            end
          end
        end 
    end
  end
end
 
