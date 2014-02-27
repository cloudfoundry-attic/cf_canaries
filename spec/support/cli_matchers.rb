module CliMatchers
  RSpec::Matchers.define :validate_successfully do
    match do |options_parser|
      options_parser.parse!
      options_parser.validate!
      true
    end
  end

  RSpec::Matchers.define :fail_validation do |message|
    match do |options_parser|
      options_parser.parse!
      begin
        options_parser.validate!
      rescue described_class::OptionError => e
        @err = e
      end

      @err.to_s.match(message)
    end

    failure_message_for_should do |_|
      if @err.nil?
        "Expected failure message matching #{message}, but got nothing"
      else
        "Expected failure message matching #{message}, got:\n#{@err.to_s}"
      end
    end
  end
end
