module Caching
  
  def cache_object(name)
    puts "caching object: #{name}"
    file = cache_path :objects, name
    if File.exists? file
      Marshal.load File.read(file)
    else
      obj = yield
      data = Marshal.dump obj
      File.open(file, "w"){ |f| f.write data }
      obj
    end
  end

  def cache_cookies(name)
    puts "caching cookies: #{name}"
    file = cache_path :cookies, name
    if File.exists? file
      @agent.cookie_jar.load file
    else
      yield
      @agent.cookie_jar.save_as file
    end
  end
  
  def cache_path(dir, name)
    "#{PATH}/tmp/#{dir}/#{name}.#{dir == :objects ? "dump" : "yml"}"
  end
  
  def cache_clear(type, name)
    FileUtils.rm_f cache_path(type, name)
  end
  
end