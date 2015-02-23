require 'zlib'

class Player < Struct.new(:entry, :nick, :uid)
  def color
    "##{'%06X' % (colorizable_hash & 0xFFFFFF)}"
  end

  def color_cls
    "nick color%d" % (colorizable_hash & 7)
  end

  def href
    "http://mc.lemonspace.me/?playername=#{nick}&mapname=#{entry.coord.map_name}&zoom=6"
  end

  private
    def colorizable_hash
      Zlib::crc32(uid || nick)
    end
end
