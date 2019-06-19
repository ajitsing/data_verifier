require 'data_verifier'

describe DataVerifier::BaselineBuilder do
  describe '#build' do
    let(:db) {double(:db)}

    before(:each) do
      expect(Sequel).to receive(:connect).and_return(db)
    end

    it 'should execute queries and store result in json files' do
      queries = {
          users_table: 'select * from users where id=100',
          addresses_table: 'select * from addresses where user_id=100'
      }

      config = DataVerifier::Config.new do |c|
        c.data_identifier = '100'
        c.queries = queries
      end

      builder = DataVerifier::BaselineBuilder.new

      expect(db).to receive(:fetch).with(queries[:users_table]).and_return(double(:users))
      expect(db).to receive(:fetch).with(queries[:addresses_table]).and_return(double(:addresses))

      expect(File).to receive(:open).with('100_users_table.json', 'w')
      expect(File).to receive(:open).with('100_addresses_table.json', 'w')

      builder.with(config).build
    end

    it 'should not add prefix to json files when identifier is not given' do
      queries = {
          users_table: 'select * from users where id=100'
      }

      config = DataVerifier::Config.new do |c|
        c.queries = queries
      end

      builder = DataVerifier::BaselineBuilder.new

      expect(db).to receive(:fetch).with(queries[:users_table]).and_return(double(:users))
      expect(File).to receive(:open).with('users_table.json', 'w')

      builder.with(config).build
    end
  end
end