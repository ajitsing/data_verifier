require 'data_verifier'

describe DataVerifier::Inspector do
  describe '#inspect' do
    let(:queries) {{
        users_table: 'select * from users where id=100',
        addresses_table: 'select * from addresses where user_id=100'
    }}

    let(:config1) {
      DataVerifier::Config.new do |c|
        c.data_identifier = '100'
        c.queries = queries
      end
    }

    let(:config2) {
      DataVerifier::Config.new do |c|
        c.data_identifier = '100'
        c.queries = queries
      end
    }

    it 'should inspect in build mode' do
      configs = [config1, config2]
      inspector = DataVerifier::Inspector.new(configs, report_name: '100_data_sanity')

      builder = instance_double(DataVerifier::BaselineBuilder)
      expect(DataVerifier::BaselineBuilder).to receive(:new).and_return(builder)

      expect(builder).to receive(:with).with(config1)
      expect(builder).to receive(:with).with(config2)
      expect(builder).to receive(:build)

      inspector.inspect(phase: :BUILD)
    end

    it 'should inspect in verify mode' do
      configs = [config1, config2]
      inspector = DataVerifier::Inspector.new(configs, report_name: '100_data_sanity')

      validator = instance_double(DataVerifier::Validator)
      expect(DataVerifier::Validator).to receive(:new).and_return(validator)

      expect(validator).to receive(:validate_using).with(config1)
      expect(validator).to receive(:validate_using).with(config2)
      expect(validator).to receive(:generate_report)

      inspector.inspect(phase: :VERIFY)
    end

    it 'should do nothing when phase is invalid' do
      inspector = DataVerifier::Inspector.new(nil, report_name: nil)
      inspector.inspect(phase: :INVALID)
    end
  end
end