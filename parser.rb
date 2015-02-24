module Parser
  Categories = [:chat, :connections, :dynmap, :deaths]
end

require_relative 'parser/index_entry'

Parser::Categories.each do |category|
  require_relative "parser/#{category}"
end
