require 'pathname'
require 'date'

class IndexEntry < Struct.new(:date, *Parser::Categories)
  def base_uri
    date.strftime '/logs/%Y/%m/%d'
  end

  Parser::Categories.each do |category|
    class_eval <<-ruby, __FILE__, __LINE__
      def #{category}_href(format=:html)
        "\#{base_uri}/#{category}.\#{format}"
      end

      alias_method :#{category}?, :#{category}
    ruby
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
        month_path.children.sort!.map! do |day_path|
          day = day_path.relative_path_from(month_path).to_s
          date = Date.parse "#{year}-#{month}-#{day}"
          catergoy_values = Parser::Categories.map do |category|
            File.exists? File.join(day_path, "#{category}.log")
          end
          new(date, *catergoy_values)
        end
      end
    end
  end
end
