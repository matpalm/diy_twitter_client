require 'redis'
class DistHash  

  def initialize id, default=nil
    @r = Redis.new
    @id = id
    @default = default
  end
  
  def get k
    v = @r.hget @id, k
    v || @default
  end

  def set k, v
    @r.hset @id, k, v
  end

end
