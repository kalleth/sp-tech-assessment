class InMemoryRepository
  def store(path, ip)
    registry[path] ||= { path: path, hits: 0, uniques: 0 }
    registry[path][:hits] += 1
    increment_unique(path, ip)
  end

  def each_by_hits
    registry.values.sort { |a, b| b[:hits] <=> a[:hits] }
  end

  def each_by_uniques
    registry.values.sort { |a, b| b[:uniques] <=> a[:uniques] }
  end

  private
  def increment_unique(path, ip)
    ip_registry[path] ||= []

    unless ip_registry[path].include?(ip)
      ip_registry[path] << ip
      registry[path][:uniques] += 1
    end
  end

  def registry
    @registry ||= {}
  end

  def ip_registry
    @ip_registry ||= {}
  end
end
