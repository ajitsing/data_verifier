require 'json'
require 'sequel'
require 'axlsx'

module DataVerifier
  class Validator
    def initialize(report_name = 'data_verifier')
      @report_name = report_name
      @excel = Axlsx::Package.new
    end

    def validate_using(config)
      db = create_db_connection(config)

      config.queries.each do |tag, query|
        puts "Executing => #{query}\n"

        new_data = db.fetch(query)
        old_data = JSON.parse(File.read(data_file_name(config, tag)))

        update_excel(tag, new_data, old_data)
      end

      self
    end

    def generate_report
      @excel.serialize("#{@report_name}.xlsx")
    end

    private
    def create_db_connection(config)
      Sequel.connect(adapter: config.db_adapter,
                     user: config.db_user,
                     password: config.db_password,
                     host: config.db_host,
                     port: config.db_port,
                     database: config.db_name,
                     max_connections: config.db_max_connections)
    end

    def update_excel(sheet_name, new_data, old_data)
      header_color = "43B275"
      header = %w(Field Before After)

      header_style_opts = {bg_color: header_color, b: true, sz: 16, alignment: {horizontal: :center}, color: white_color}
      data_style_opts   = {sz: 13, alignment: {horizontal: :left}}
      error_style_opts  = {sz: 12, alignment: {horizontal: :left}, color: red_color, b: true}

      @excel.workbook.add_worksheet(name: sheet_name.to_s) do |s|
        header_style      = s.styles.add_style header_style_opts
        data_style        = s.styles.add_style data_style_opts
        error_data_style  = s.styles.add_style error_style_opts

        s.add_row header, style: header_style
        s.row_style(0, header_style)

        new_data.each_with_index do |db_row, index|
          baseline_row = old_data[index]

          db_row.each do |db_field, new_value|
            field = db_field.to_s.upcase
            old_value = baseline_row.nil? ? "" : baseline_row[db_field.to_s].to_s
            cell_style = old_value == new_value.to_s ? data_style : error_data_style

            s.add_row [field, old_value, new_value.to_s], style: [cell_style, cell_style, cell_style]
          end

          s.add_row empty_row
          s.add_row empty_row, style: [header_style, header_style, header_style]
          s.add_row empty_row
        end
      end
    end

    def data_file_name(config, tag)
      "#{identifier(config)}#{tag}.json"
    end

    def identifier(config)
      config.data_identifier.nil? ? '' : "#{config.data_identifier}_"
    end

    def empty_row
      ["", "", ""]
    end

    def red_color
      red_color = Axlsx::Color.new
      red_color.rgb = 'C40101'

      red_color
    end

    def white_color
      white_color = Axlsx::Color.new
      white_color.rgb = 'FFFFFF'

      white_color
    end
  end
end
