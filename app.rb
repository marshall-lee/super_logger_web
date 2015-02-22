require 'sinatra'
require 'slim'
require 'date'
require 'pathname'

require_relative 'parser/index_entry'
require_relative 'parser/chat'

set :server, :thin

configure do
  enable :inline_templates
  if development?
    set :log_dir, File.join(File.dirname(__FILE__), 'sample_logs')
  else
    set :log_dir, "/home/minecraft/spigot/plugins/SuperLogger/logs"
  end
end


get '/logs' do
  @entries = IndexEntry.from_dir(settings.log_dir).reverse!
  slim :index
end

get %r{/logs/(\d\d\d\d)/(\d\d)/(\d\d)/(chat|connections)(\.(txt|html))?} do |year, month, day, type, _, format|
  date = begin
           Date.parse "#{year}-#{month}-#{day}"
         rescue ArgumentError
           halt 400
         end

  format = (format || :txt).to_sym
  type = type.to_sym

  path = File.join settings.log_dir,
                   date.strftime("%Y"),
                   date.strftime("%m"),
                   date.strftime("%d"),
                   "#{type}.log"

  unless File.exists? path
    halt 404
  end

  file = File.open(path, "r")

  case format
  when :txt
    content_type :text
    file.read
  when :html
    content_type :html
    case type
    when :chat
      @title = "Chat #{date.strftime("%Y-%m-%d")}"
      @parser = Chat.new(file)
    when :connections
      # TODO: implement
    end
    slim type
  else
    halt 400
  end
end
