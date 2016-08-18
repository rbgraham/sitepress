require "pathname"
require "mascot/extensions/proc_manipulator"

module Mascot
  # A collection of pages from a directory.
  class Site
    # Default file pattern to pick up in site
    DEFAULT_GLOB = "**/**".freeze
    # Default root path for site.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    attr_reader :root, :resources_pipeline

    def initialize(root: DEFAULT_ROOT_PATH)
      self.root = root
    end

    # Lazy stream of files that will be rendered by resources.
    def assets(glob = DEFAULT_GLOB)
      safe_root.glob(root.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    def glob(glob)
      paths = safe_root.glob(root.join(glob))
      resources.select{ |r| paths.include? r.asset.path.to_s }
    end

    # Returns a list of resources.
    def resources
      ResourcesNode.new.tap do |root_node|
        assets.each { |a| root_node.add path: asset_path_to_request_path(a), asset: a }
        resources_pipeline.process root_node
      end
    end

    # Quick and dirty way to manipulate resources in the site without
    # creating classes that implement the #process_resources method
    def manipulate(&block)
      resources_pipeline << Extensions::ProcManipulator.new(block)
    end

    # Find the page with a path.
    def get(request_path)
      resources.get_resource(request_path)
    end

    def root=(path)
      @root = Pathname.new(path)
    end

    def resources_pipeline
      @resources_pipeline ||= ResourcesPipeline.new
    end

    private
    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def asset_path_to_request_path(asset)
      # Relative path of resource to the file_path of this project.
      asset.path.dirname.join(asset.format_basename).relative_path_from(root).to_s
    end

    def safe_root
      SafeRoot.new(path: root)
    end
  end
end
