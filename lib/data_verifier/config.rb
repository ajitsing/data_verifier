module DataVerifier
  class Config
    attr_accessor :db_adapter, :db_user, :db_password, :db_name, :db_host, :db_port, :db_max_connections, :queries, :data_identifier

    def initialize
      @db_adapter = nil
      @db_user = nil
      @db_password = nil
      @db_host = nil
      @db_port = nil
      @db_name = nil
      @db_max_connections = 25
      @data_identifier = nil
      @queries = {}

      yield self if block_given?
    end
  end
end
