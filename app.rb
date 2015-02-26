require 'sinatra'
require 'sinatra/partial'
require 'coffee_script'
require 'slim'
require 'date'
require 'pathname'

require_relative 'parser'

require_relative 'file_listener'
require_relative 'global_faye_client'

set :server, :thin

configure do
  set :partial_template_engine, :slim
  if production?
    set :log_dir, "/home/minecraft/spigot/plugins/SuperLogger/logs"
    set :faye_url, 'http://mc.lemonspace.me/logs/faye'
  else
    set :log_dir, File.join(File.dirname(__FILE__), 'sample_logs')
    set :faye_url, 'http://localhost:4000/logs/faye'
  end
end

helpers do
  def parser_class(category)
    Kernel.const_get(category.to_s.split('_').collect(&:capitalize).join)
  end

  def listener
    FileListener.instance
  end

  def faye
    GlobalFayeClient.instance
  end
end


get '/logs' do
  @entries = IndexEntry.from_dir(settings.log_dir).reverse!
  slim :index
end

before %r{\.html$} do
  expires 60*2, :public, :must_revalidate
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

before %r{^/logs/\d\d\d\d/\d\d/\d\d/#{Parser::Categories.join '|'}|all\.html} do
  faye_base = "/#{@date.strftime '%Y/%m/%d'}"
  @faye_base = faye_base
  Parser::Categories.each do |category|
    path = File.join @log_dir, "#{category}.log"
    next unless File.exists? path
    tomorrow = (@date.to_time + 60*60*24).to_date.to_time
    entry_class = parser_class(category)::Entry
    unless listener.listens? path
      listener.add(path, expires: tomorrow) do |position, line|
        entry = entry_class.parse(line, position)
        data = {
          row: {
            id: "#{category}-row-#{entry.line_no}",
            html: partial("#{category}_tr", locals: { entry: entry })
          }
        }
        faye.publish "#{faye_base}/#{category}", data
      end
    end
  end
end

get %r{^/logs/\d\d\d\d/\d\d/\d\d/(#{Parser::Categories.join '|'})\.(txt|html)$} do |category, format|
  format = format.to_sym
  category = category.to_sym

  path = File.join @log_dir, "#{category}.log"

  unless File.exists? path
    halt 404
  end

  last_modified File.mtime(path)

  file = File.open(path, "r")

  case format
  when :txt
    content_type :text
    file.read
  when :html
    content_type :html
    @faye_channel = "#{@faye_base}/#{category}"
    @title = "#{category.to_s.capitalize} log / #{@date_str}"
    @parser = parser_class(category).new(file)
    slim category
  else
    halt 400
  end
end

get %r{^/logs/\d\d\d\d/\d\d/\d\d/all.html$} do
  paths = Parser::Categories.map { |category| File.join @log_dir, "#{category}.log" }
  categories_with_paths = Parser::Categories.zip paths
  categories_with_paths.select! do |_, path|
    File.exists? path
  end

  last_modified categories_with_paths.map { |_, path| File.mtime(path) }.max

  @data = categories_with_paths.flat_map do |category, path|
    parser_class(category).new(File.open(path)).to_a
  end
  @data.sort_by!(&:time)

  @faye_channel = "#{@faye_base}/*"
  @title = "Log / #{@date_str}"

  slim :all
end
