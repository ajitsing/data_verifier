module DataVerifier
  class Inspector
    def initialize(configs, report_name:)
      @configs = configs
      @report_name = report_name
    end

    def inspect(phase:)
      if phase == :BUILD
        puts "Running in :BUILD mode...\n"
        build_baseline_data
      elsif phase == :VERIFY
        puts "Running in :VERIFY mode...\n"
        validate_data
      else
        puts "Please pass a valid phase, valid values are :BUILD and :VERIFY\n"
      end
    end

    private
    def build_baseline_data
      builder = DataVerifier::BaselineBuilder.new
      @configs.each {|config| builder.with(config)}
      builder.build
    end

    def validate_data
      validator = DataVerifier::Validator.new(@report_name)
      @configs.each {|config| validator.validate_using(config)}
      validator.generate_report
    end
  end
end