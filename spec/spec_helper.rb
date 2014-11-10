require 'f5/icontrol'
require 'vcr'

RSpec.configure do |c|
  # https://github.com/docwhat/homedir/blob/homedir3/spec/spec_helper.rb
  # Captures the output for analysis later
  #
  # @example Capture `$stderr`
  #
  #     output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr`
  # @yield The block to capture stdout/stderr for.
  # @return [String] The contents of $stdout or $stderr
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into             :webmock
  c.default_cassette_options = { :record => :new_episodes }
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false
end
