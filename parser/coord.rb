class Coord < Struct.new(:world_name, :x, :y, :z)
  def href
    "http://mc.lemonspace.me/?worldname=#{world_name}&mapname=#{map_name}&x=#{x}&y=#{y}&z=#{z}&zoom=6"
  end

  def map_name
    case world_name
    when :world then :surface
    when :world_nether then :nether
    when :world_the_end then :the_end
    end
  end

  def to_s
    "(#{x},#{y},#{z})"
  end
end
