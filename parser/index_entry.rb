require 'pathname'
require 'date'

class IndexEntry < Struct.new(:date)
  def base_uri
    date.strftime '/logs/%Y/%m/%d'
  end

  def chat_href(format=:html)
    "#{base_uri}/chat.#{format}"
  end

  def connections_href(format=:html)
    "#{base_uri}/connections.#{format}"
  end

  def dynmap_href(format=:html)
    "#{base_uri}/dynmap.#{format}"
  end

  def deaths_href(format=:html)
    "#{base_uri}/deaths.#{format}"
  end

  def all_href
    "#{base_uri}/all.html"
  end

  def self.from_dir(dirname)
    root = Pathname.new dirname
    root.children.sort!.flat_map do |year_path|
      year = year_path.relative_path_from(root).to_s
      year_path.children.sort!.flat_map do |month_path|
        month = month_path.relative_path_from(year_path).to_s
        month_path.children.sort!.flat_map do |day_path|
          day = day_path.relative_path_from(month_path).to_s
          date = Date.parse "#{year}-#{month}-#{day}"
          new(date)
        end
      end
    end
  end
end
