class Player < Struct.new(:entry, :nick, :uid)
  def color
    "##{'%06X' % (uid.hash & 0xFFFFFF)}"
  end

  def color_cls
    "nick color%d" % (uid.hash & 7)
  end

  def href
    "http://mc.lemonspace.me/?playername=#{nick}&mapname=#{entry.coord.map_name}&zoom=6"
  end
end
