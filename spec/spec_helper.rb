Dir.glob(File.expand_path('../support/*.rb', __FILE__)).each do |support|
  require support
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.include(CliMatchers)

  config.before do
    allow(Process).to receive(:spawn).and_raise('It is unsafe to call Process.spawn in a spec')
    allow(IO).to receive(:popen).and_raise('It is unsafe to call IO.popen in a spec')
  end
end
