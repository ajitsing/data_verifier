require 'data_verifier'

describe DataVerifier::Validator do
  describe '#generate_validation_file' do
    let(:db) {double(:db)}

    before(:each) do
      expect(Sequel).to receive(:connect).and_return(db)
    end

    it 'should create result excel file' do
      config = DataVerifier::Config.new do |c|
        c.data_identifier = 'rspec'
        c.queries = {q1: 'select * from users', q2: 'select * from addresses where user_id=1'}
      end

      validator = DataVerifier::Validator.new(config)

      excel = double(:execel)
      expect(Axlsx::Package).to receive(:new).and_return(excel)

      expect(db).to receive(:fetch).with('select * from users').and_return(double(:users))
      expect(db).to receive(:fetch).with('select * from addresses where user_id=1').and_return(double(:addresses))

      expect(File).to receive(:read).with('rspec_q1.json').and_return("{}")
      expect(File).to receive(:read).with('rspec_q2.json').and_return("{}")


      work_book = double(:workbook)
      expect(excel).to receive(:workbook).and_return(work_book).twice

      expect(work_book).to receive(:add_worksheet).with(name: 'q1')
      expect(work_book).to receive(:add_worksheet).with(name: 'q2')

      expect(excel).to receive(:serialize).with('rspec_data_verifier_result.xlsx')

      validator.generate_validation_file
    end

    it 'should create result excel file' do
      config = DataVerifier::Config.new do |c|
        c.queries = {}
      end

      validator = DataVerifier::Validator.new(config)

      excel = double(:execel)
      expect(Axlsx::Package).to receive(:new).and_return(excel)
      expect(excel).to receive(:serialize).with('data_verifier_result.xlsx')

      validator.generate_validation_file
    end
  end
end