require 'time'

require_relative 'base_entry'
require_relative 'player'
require_relative 'coord'

class Connections
  RegExp = %r{\[(../../..) - (..:..:..)\] \[(JOIN|QUIT)\] (.+) \(([a-f0-9-]+)\) at \((-?\d+), (-?\d+), (-?\d+)\) in world '(\w+)'}

  class Entry < Struct.new(:time, :type, :player, :coord)
    include BaseEntry

    def self.parse(line)
      data = RegExp.match line

      date_parts = data[1].split '/'
      time_part = data[2]
      time = Time.parse("#{date_parts[2]}-#{date_parts[0]}-#{date_parts[1]} #{time_part}")

      type = data[3].downcase.to_sym

      nick = data[4]
      uid = data[5]
      player = Player.new nil, nick, uid

      x,y,z = data[6..8].map(&:to_i)
      world_name = data[9].to_sym
      coord = Coord.new world_name, x, y, z

      entry = new time, type, player, coord
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
      yield Entry.parse(line)
    end
  end
end
