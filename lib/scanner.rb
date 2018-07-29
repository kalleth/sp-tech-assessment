class Scanner
  # @param handle [IO] An IO object responding to #each_line
  # @return [Scanner]
  def initialize(handle)
    @handle = handle
  end

  def each_entry
    handle.each_line do |line|
      # For now, let's split by an empty space, as that's the format we've been
      # given. Will have to have a think about how robust this is.
      path, ip = line.split(" ")
      yield path, ip
    end
  end

  private
  attr_reader :handle
end
