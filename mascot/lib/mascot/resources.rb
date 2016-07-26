module Mascot
  class Resources
    include Enumerable

    extend Forwardable
    def_delegators :@resources, :size

    def initialize(root_file_path: )
      @resources = Array.new
      @root_file_path = Pathname.new(root_file_path)
    end

    def each(&block)
      @resources.each(&block)
    end

    def glob(pattern = "**/**")
      paths = path_validator.glob @root_file_path.join(pattern)
      @resources.select { |r| paths.include? r.asset.path.to_s}
    end

    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def format_request_path(path)
      # Relative path of resource to the file_path of this project.
      relative_path = Pathname.new(path).relative_path_from(@root_file_path)
      # Removes the .fooz.baz
      File.join("/", relative_path).to_s.sub(/\..*/, '')
    end

    def add(resource)
      @resources.push resource
    end

    def add_asset(asset, request_path: nil)
      add Resource.new asset: asset, request_path: format_request_path(request_path || asset.path)
    end

    def get(request_path)
      return if request_path.nil?
      @resources.find { |r| r.request_path == File.join("/", request_path) }
    end

    private
    def path_validator
      @path_validator ||= PathValidator.new(safe_path: @root_file_path)
    end
  end
end