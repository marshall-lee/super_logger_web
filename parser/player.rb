class Player < Struct.new(:nick, :uid)
  def color
    "##{'%06X' % (uid.hash & 0xFFFFFF)}"
  end

  def to_s
    "<#{nick}>"
  end
end
