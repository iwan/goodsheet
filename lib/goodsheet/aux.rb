class Object
  def chrono(msg, &block)
    puts "--------- starting #{msg} -------->"
    t = Time.now
    yield
    delta_t = Time.now-t
    puts "<-------- #{msg} takes #{delta_t}s"
    return delta_t
  end
end
