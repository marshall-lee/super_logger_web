require 'time'

require_relative 'player'
require_relative 'coord'

class Chat
  RegExp = %r{\[(../../..) - (..:..:..)\] (.+) \(([a-f0-9-]+)\) at \((-?\d+), (-?\d+), (-?\d+)\) in world '(\w+)' : (.+)$}

  class Entry < Struct.new(:time, :player, :coord, :text)
    def time_s
      time.strftime '%H:%M'
    end
  end

  include Enumerable

  def initialize(file)
    @file = file
  end


  def each
    @file.each_line do |line|
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

      entry = Entry.new time, player, coord, text
      player.entry = entry

      yield entry
    end
  end

  private

  attr_reader :file
end
