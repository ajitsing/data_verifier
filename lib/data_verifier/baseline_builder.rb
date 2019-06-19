require 'json'
require 'sequel'

module DataVerifier
  class BaselineBuilder
    def initialize
      @configs = []
    end

    def with(config)
      @configs << config
      self
    end

    def build
      @configs.each do |config|
        db = create_db_connection(config)

        config.queries.each do |tag, query|
          puts "Executing => #{query}\n"
          data = db.fetch(query)

          File.open(data_file_name(config, tag), 'w') do |file|
            file.write JSON.dump(data.all)
          end
        end
      end
    end

    private
    def data_file_name(config, tag)
      identifier = config.data_identifier.nil? ? '' : "#{config.data_identifier}_"
      "#{identifier}#{tag}.json"
    end

    def create_db_connection(config)
      Sequel.connect(adapter: config.db_adapter,
                     user: config.db_user,
                     password: config.db_password,
                     host: config.db_host,
                     port: config.db_port,
                     database: config.db_name,
                     max_connections: config.db_max_connections)
    end
  end
end
