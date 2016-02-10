require "#{File.expand_path('../../', __FILE__)}/test_helper.rb"

Dir["#{File.expand_path('../../../', __FILE__)}/lib/*.rb"].each {|file| require file }
Dir["#{File.expand_path('../../../', __FILE__)}/lib/**/*.rb"].each {|file| require file }

class BaseUnitTest < Minitest::Test
  include TestHelper
end
