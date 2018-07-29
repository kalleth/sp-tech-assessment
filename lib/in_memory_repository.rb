class InMemoryRepository
  def store(path, ip)
    registry[path] ||= { path: path, hits: 0 }
    registry[path][:hits] += 1
  end

  def each_by_hits
    registry.values.sort { |a, b| b[:hits] <=> a[:hits] }
  end

  private
  def registry
    @registry ||= {}
  end
end
