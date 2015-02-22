require 'time'
require 'ostruct'

require_relative 'player'
require_relative 'coord'

class Dynmap
  RegExp = %r{\[(../../..) - (..:..:..)\] (.+) \((\w+)\) (.+)$}
  Coord = OpenStruct.new href: 'http://mc.lemonspace.me/'
  def Coord.to_s
    'dynmap'
  end

  class Entry < Struct.new(:time, :source, :player, :text)
    def time_s
      time.strftime '[%Y-%m-%d %H:%M:%S]'
    end

    def coord
      Coord
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

      source = data[4].downcase.to_sym

      nick = data[3]
      player = Player.new nick, nil

      text = data[5]

      yield Entry.new(time, source, player, text)
    end
  end
end
