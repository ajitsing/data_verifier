require 'data_verifier'

describe DataVerifier::BaselineBuilder do
  describe '#build' do
    let(:db) {double(:db)}

    before(:each) do
      expect(Sequel).to receive(:connect).and_return(db)
    end

    it 'should execute queries and store result in json files' do
      config = DataVerifier::Config.new do |c|
        c.data_identifier = 'rspec'
        c.queries = {q1: 'select * from users', q2: 'select * from addresses where user_id=1'}
      end

      builder = DataVerifier::BaselineBuilder.new(config)

      expect(db).to receive(:fetch).with('select * from users').and_return(double(:users))
      expect(db).to receive(:fetch).with('select * from addresses where user_id=1').and_return(double(:addresses))

      expect(File).to receive(:open).with('rspec_q1.json', 'w')
      expect(File).to receive(:open).with('rspec_q2.json', 'w')

      builder.build
    end

    it 'should not add prefix to json files when identifier is not given' do
      config = DataVerifier::Config.new do |c|
        c.queries = {q1: 'select * from users'}
      end

      builder = DataVerifier::BaselineBuilder.new(config)

      expect(db).to receive(:fetch).with('select * from users').and_return(double(:users))
      expect(File).to receive(:open).with('q1.json', 'w')

      builder.build
    end
  end
end