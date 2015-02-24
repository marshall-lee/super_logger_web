require 'faye'
require 'singleton'

class GlobalFayeClient < Faye::Client
  include Singleton

  def initialize
    super(Sinatra::Application.settings.faye_url)
  end
end
