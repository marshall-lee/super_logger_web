class Coord < Struct.new(:world_name, :x, :y, :z)
  def href
    "http://mc.lemonspace.me/?worldname=#{world_name}&mapname=surface&x=#{x}&y=#{y}&z=#{z}&zoom=6"
  end
end
