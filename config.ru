require 'faye'
require File.expand_path '../app.rb', __FILE__

use Faye::RackAdapter, mount: '/logs/faye', timeout: 25

Faye::WebSocket.load_adapter 'thin'

run Sinatra::Application
