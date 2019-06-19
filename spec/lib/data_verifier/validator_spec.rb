require 'data_verifier'

describe DataVerifier::Validator do
  describe '#generate_validation_file' do
    let(:db) {double(:db)}

    before(:each) do
      expect(Sequel).to receive(:connect).and_return(db)
    end

    it 'should create result excel file' do
      queries = {
          users_table: 'select * from users where id=100',
          addresses_table: 'select * from addresses where user_id=100'
      }

      config = DataVerifier::Config.new do |c|
        c.data_identifier = '100'
        c.queries = queries
      end

      excel = double(:excel)
      expect(Axlsx::Package).to receive(:new).and_return(excel)

      validator = DataVerifier::Validator.new('test_result')

      expect(db).to receive(:fetch).with(queries[:users_table]).and_return(double(:users))
      expect(db).to receive(:fetch).with(queries[:addresses_table]).and_return(double(:addresses))

      expect(File).to receive(:read).with('100_users_table.json').and_return("{}")
      expect(File).to receive(:read).with('100_addresses_table.json').and_return("{}")

      work_book = double(:workbook)
      expect(excel).to receive(:workbook).and_return(work_book).twice

      expect(work_book).to receive(:add_worksheet).with(name: 'users_table')
      expect(work_book).to receive(:add_worksheet).with(name: 'addresses_table')

      expect(excel).to receive(:serialize).with('test_result.xlsx')

      validator.validate_using(config).generate_report
    end
  end
end