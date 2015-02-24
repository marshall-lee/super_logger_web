require 'time'

require_relative 'base_entry'
require_relative 'player'
require_relative 'coord'

class Chat
  RegExp = %r{\[(../../..) - (..:..:..)\] (.+) \(([a-f0-9-]+)\) at \((-?\d+), (-?\d+), (-?\d+)\) in world '(\w+)' : (.+)$}

  class Entry < Struct.new(:time, :line_no, :player, :coord, :text)
    include BaseEntry

    def self.parse(line, line_no=nil)
      data = RegExp.match line

      date_parts = data[1].split '/'
      time_part = data[2]
      time = Time.parse("#{date_parts[2]}-#{date_parts[0]}-#{date_parts[1]} #{time_part}")

      nick = data[3]
      uid = data[4]
      player = Player.new nil, nick, uid

      x,y,z = data[5..7].map(&:to_i)
      world_name = data[8].to_sym
      coord = Coord.new world_name, x, y, z

      text = data[9]

      entry = new time, line_no, player, coord, text
      player.entry = entry

      return entry
    end
  end

  include Enumerable

  def initialize(file)
    @file = file
  end

  def each
    @file.each_line do |line|
      yield Entry.parse(line, @file.pos)
    end
  end

  private

  attr_reader :file
end
