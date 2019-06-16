require 'json'
require 'sequel'

module DataVerifier
  class BaselineBuilder
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

    def build
      @config.queries.each do |tag, query|
        puts "Executing => #{query}\n"
        data = @db.fetch(query)

        File.open(data_file_name(tag), 'w') do |file|
          file.write JSON.dump(data.all)
        end
      end
    end

    private
    def data_file_name(tag)
      identifier = @config.data_identifier.nil? ? '' : "#{@config.data_identifier}_"
      "#{identifier}#{tag}.json"
    end
  end
end
