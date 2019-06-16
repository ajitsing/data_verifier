require 'json'
require 'sequel'
require 'axlsx'

module DataVerifier
  class Validator
    def initialize(config)
      @config = config
      @db = Sequel.connect(adapter: @config.db_adapter,
                           user: @config.db_user,
                           password: @config.db_password,
                           host: @config.db_host,
                           port: @config.db_port,
                           database: @config.db_name,
                           max_connections: @config.db_max_connections)
    end

    def generate_validation_file
      excel = Axlsx::Package.new

      @config.queries.each do |tag, query|
        puts "Executing => #{query}\n"
        data = @db.fetch(query)
        update_excel(excel, tag, data)
      end

      excel.serialize("#{identifier}data_verifier_result.xlsx")
    end

    private
    def update_excel(excel, sheet_name, data)
      data_before_replication = JSON.parse(File.read(data_file_name(sheet_name)))

      excel.workbook.add_worksheet(name: sheet_name.to_s) do |s|
        header_style = s.styles.add_style bg_color: "43B275", b: true, sz: 16, alignment: {horizontal: :center}, color: white_color
        data_style = s.styles.add_style sz: 13, alignment: {:horizontal => :left}
        error_data_style = s.styles.add_style sz: 12, alignment: {:horizontal => :left}, color: red_color, b: true

        s.add_row ["Field", "Before", "After"], style: header_style
        s.row_style(0, header_style)

        data.each_with_index do |db_row, index|
          stored_result = data_before_replication[index]

          db_row.each do |column, value|
            value_not_eql = stored_result[column.to_s].to_s != value.to_s
            data = [column.to_s.upcase, stored_result[column.to_s].to_s, value.to_s]

            conditional_formatting = value_not_eql ? error_data_style : data_style
            s.add_row data, style: [conditional_formatting, data_style, data_style]
          end

          s.add_row ["", "", ""]
          s.add_row ["", "", ""], style: [header_style, header_style, header_style]
          s.add_row ["", "", ""]
        end
      end
    end

    def data_file_name(tag)
      "#{identifier}#{tag}.json"
    end

    def identifier
      @config.data_identifier.nil? ? '' : "#{@config.data_identifier}_"
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
