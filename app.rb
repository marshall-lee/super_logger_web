require 'sinatra'
require 'sinatra/partial'
require 'slim'
require 'date'
require 'pathname'

require_relative 'parser'

set :server, :thin

configure do
  set :partial_template_engine, :slim
  if development?
    set :log_dir, File.join(File.dirname(__FILE__), 'sample_logs')
  else
    set :log_dir, "/home/minecraft/spigot/plugins/SuperLogger/logs"
  end
end

helpers do
  def parser_class(category)
    Kernel.const_get(category.to_s.split('_').collect(&:capitalize).join)
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

get %r{^/logs/\d\d\d\d/\d\d/\d\d/(#{Parser::Categories.join '|'})\.(txt|html)$} do |category, format|
  format = format.to_sym
  category = category.to_sym

  path = File.join @log_dir, "#{category}.log"

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
    @title = "#{category.to_s.capitalize} log / #{@date_str}"
    @parser = parser_class(category).new(file)
    slim category
  else
    halt 400
  end
end

get %r{^/logs/\d\d\d\d/\d\d/\d\d/all.html$} do
  @data = Parser::Categories.flat_map do |category|
    path = File.join @log_dir, "#{category}.log"
    if File.exists? path
      parser_class(category).new(File.open(path)).to_a
    else
      []
    end
  end
  @data.sort_by!(&:time)

  @title = "Log / #{@date_str}"

  slim :all
end
