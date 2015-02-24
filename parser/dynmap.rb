require 'time'
require 'ostruct'

require_relative 'base_entry'
require_relative 'player'

class Dynmap
  RegExp = %r{\[(../../..) - (..:..:..)\] (.+) \((\w+)\) (.+)$}
  Coord = OpenStruct.new href: 'http://mc.lemonspace.me/',
                         map_name: nil
  def Coord.to_s
    'dynmap'
  end

  class Entry < Struct.new(:time, :source, :player, :text)
    include BaseEntry

    def coord
      Coord
    end

    def self.parse(line)
      data = RegExp.match line

      date_parts = data[1].split '/'
      time_part = data[2]
      time = Time.parse("#{date_parts[2]}-#{date_parts[0]}-#{date_parts[1]} #{time_part}")

      source = data[4].downcase.to_sym

      nick = data[3]
      player = Player.new nil, nick, nil

      text = data[5]

      entry = new(time, source, player, text)
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
