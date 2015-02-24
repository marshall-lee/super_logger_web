module Parser
  Categories = [:chat, :connections, :dynmap, :deaths].freeze
end

require_relative 'parser/index_entry'

Parser::Categories.each do |category|
  require_relative "parser/#{category}"
end
