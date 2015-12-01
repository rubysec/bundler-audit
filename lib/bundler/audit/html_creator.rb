module Bundler
  module Audit
    class HTMLCreator

      attr_accessor :file

      def self.from(file_name)
        file_name = 'audit.html' if file_name == 'output'
        self.new file_name
      end

      def initialize(file_name)
        @file = File.open file_name, 'wb'
      end

      def done!
        file.close
      end

      def write_top_html(sources_count, vulnerable_count)
        sources_html = case sources_count
        when 0 then %Q{<span class="label label-success">0</span> Insecure sources found}
        when 1 then %Q{<span class="label label-warning">1</span> Insecure source found}
        else        %Q{<span class="label label-danger">#{sources_count}</span> Insecure sources found!}
        end

        vulnerable_html = case vulnerable_count
        when 0 then %Q{<span class="label label-success">0</span> vulnerabilities found}
        when 1 then %Q{<span class="label label-warning">1</span> vulnerability found!}
        else        %Q{<span class="label label-danger">#{vulnerable_count}</span> vulnerabilities found!}
        end

        top = <<-HTML
          <html>
          <head>
            <title>Gemfile.lock Audit</title>
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
          </head>
          <body>
            <div class="container-fluid">
              <div class="row">
                <div class="col-md-1"></div>
                <div class="col-md-10">
                  <div class="page-header">
                    <h1>
                      Vulnerability Report:
                      <small>#{sources_html} / #{vulnerable_html}</small>
                    </h1>
                  </div>
                  <div>
                    <div class = "row">
                      <div class = "col-md-5"
                        <ul class="list-group">
                          <li class="list-group-item">
                            <span class="badge">#{VERSION}</span> Version:
                          </li>
                          <li class="list-group-item">
                            <span class="badge">#{Database.new.size}</span> Database size:
                          </li>
                        </ul>
                        <br/>
                        <p>More info at https://github.com/rubysec/bundler-audit</p>
                      </div>
                    </div>
          HTML
        file << top
        self
      end

      def write_list_top
        list_topper = <<-HTML
          <h2> Insecure Source URI's:</h2>
          <dl class="dl-horizontal">
        HTML
        file << list_topper
        self
      end

      def write_list_bottom
        list_bottom = <<-HTML
          </dl>
          <br>
        HTML
        file << list_bottom
        self
      end

      def write_table_top
        table_top = <<-HTML
          <h2>Vulnerabilities</h2>
          <table class='table table-condensed table-bordered'>
            <thead>
              <th> Gem </th>
              <th> Version </th>
              <th> Vulnerability Name </th>
              <th> Severity </th>
              <th> Title </th>
              <th> Solution </th>
            </thead>
          <tbody>
          HTML
        file << table_top
        self
      end

      def write_table_bottom
        table_bottom = <<-HTML
            </tbody>
          </table>
        HTML
        file << table_bottom
        self
      end

      def write_bottom_html
        bottom_html = <<-HTML
                </div>
              <div class="col-md-1"></div>
            </div>
          </body>
        </html>
        HTML
        file << table_bottom
        self
      end

      def write_source_warning(name, source_uri)
        file << "<dt> - #{name}:</dt>\n<dd>#{source_uri}</dd>\n"
      end

      def write_advisory(gem, advisory)
        row_klass = case advisory.criticality
          when :low    then :info
          when :medium then :warning
          when :high   then :danger
          end

        gem_name = gem.name
        version  = gem.version
        name     = advisory.cve ? "CVE-#{advisory.cve}" : advisory.osvdb
        severity = advisory.criticality
        severity = 'Unknown' if severity.nil? || severity.empty?
        url      = "<a href='#{advisory.url}'>#{name}</a>"
        desc     = advisory.description
        title    = advisory.title

        if advisory.patched_versions.empty?
          solution = "Remove or disable this gem until a patch is available!"
        else
          solution = "Upgrade to #{advisory.patched_versions.join ', '}"
        end

        info  = "<tr class='#{row_klass}'>"
        info << "<td><b>#{gem_name}</b>"
        info << "<td>#{version}</td>"
        info << "<td>#{url}</td>"
        info << "<td>#{severity}</td>"
        info << "<td>#{title}</td>"
        info << "<td>#{solution}</td>"
        info << "</tr>\n"
        info << "<tr class='#{row_klass}'><td> </td><td colspan='6'>#{desc}</td></tr>\n"
        file << info
      end
    end
  end
end
