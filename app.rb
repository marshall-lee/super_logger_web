require 'sinatra'
require 'sinatra/partial'
require 'slim'
require 'date'
require 'pathname'

require_relative 'parser/index_entry'
require_relative 'parser/chat'
require_relative 'parser/connections'

set :server, :thin

configure do
  set :partial_template_engine, :slim
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

before %r{^/logs/(\d\d\d\d)/(\d\d)/(\d\d)/} do |year, month, day|
  @date = begin
            Date.parse "#{year}-#{month}-#{day}"
          rescue ArgumentError
            halt 400
          end
  @date_str = @date.strftime("%Y-%m-%d")
  @log_dir = File.join settings.log_dir,
                       @date.strftime("%Y"),
                       @date.strftime("%m"),
                       @date.strftime("%d")
end

get %r{^/logs/\d\d\d\d/\d\d/\d\d/(chat|connections)\.(txt|html)$} do |type, format|
  format = format.to_sym
  type = type.to_sym

  path = File.join @log_dir, "#{type}.log"

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
      @title = "Chat #{@date_str}"
      @parser = Chat.new(file)
    when :connections
      @title = "Connections #{@date_str}"
      @parser = Connections.new(file)
    end
    slim type
  else
    halt 400
  end
end

get %r{^/logs/\d\d\d\d/\d\d/\d\d/all.html$} do
  @data = [:chat, :connections].flat_map do |type|
    path = File.join @log_dir, "#{type}.log"
    parser_class = Kernel.const_get type.to_s.split('_').collect(&:capitalize).join
    if File.exists? path
      parser_class.new(File.open(path)).to_a
    else
      []
    end
  end
  @data.sort_by!(&:time)

  slim :all
end
