require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/mini_test'
require 'json'

module TestHelper
  ENV['environment'] = 'test'

  def fixture(name, ext = 'json')
    filename = File.expand_path("../fixtures/#{name}.#{ext}", __FILE__)
    if ext == 'json'
      JSON.parse(File.read(filename))
    else
      File.read(filename)
    end
  end
end
