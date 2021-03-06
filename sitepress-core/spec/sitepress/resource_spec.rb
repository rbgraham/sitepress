require "spec_helper"

context Sitepress::Resource do
  let(:asset_path) { "spec/sites/sample/pages/test.html.haml" }
  let(:asset) { Sitepress::Asset.new(path: asset_path) }
  let(:request_path) { asset.to_request_path }
  let(:node) { Sitepress::ResourcesNode.new }
  subject { node.add path: "/test.html", asset: asset }

  it "has #mime_type" do
    expect(subject.mime_type.to_s).to eql("text/html")
  end
  it "has #data" do
    expect(subject.data["title"]).to eql("Name")
  end
  it "has #body" do
    expect(subject.body).to include("This is just some content")
  end
  it "has #inspect" do
    expect(subject.inspect).to include(request_path)
  end
  describe "#request_path" do
    it "infers request_path from Asset#to_request_path" do
      expect(subject.request_path).to eql("/test.html")
    end
  end
  describe "resource node relationships" do
    let(:site) { Sitepress::Site.new(root_path: "spec/sites/tree") }
    let(:root) { site.root }
    subject{ root.get(path) }
    context "/about.html" do
      let(:path) { "/about.html" }
      it "has parents" do
        expect(subject.parents).to eql([nil])
      end
      it "has no parent" do
        expect(subject.parent).to be_nil
      end
      it "has siblings" do
        expect(subject.siblings).to eql([root.get("/index.html")])
      end
      it "has no children" do
        expect(subject.children).to be_empty
      end
    end
    context "/vehicles/cars/compacts.html" do
      let(:path) { "/vehicles/cars/compacts.html" }
      let(:parents_paths) { subject.parents(**filter).map{ |n| n.request_path if n } }
      let(:parent_path) { subject.parent(**filter).request_path }
      context "parents" do
        context "no filter" do
          let(:filter){ {} }
          it "has 3 parents" do
            expect(parents_paths).to eql(["/vehicles/cars.html", nil, nil])
          end
          it "has 1 parent" do
            expect(parent_path).to eql("/vehicles/cars.html")
          end
        end
        context "ext string filter" do
          let(:filter) { {type: ".xml"} }
          it "has 1 xml parent, 2 nil parents" do
            expect(parents_paths).to match_array(["/vehicles/cars.xml", nil, nil])
          end
          it "has 1 xml parent" do
            expect(parent_path).to eql("/vehicles/cars.xml")
          end
        end
        context "MIME::Types filter" do
          let(:filter) { {type: MIME::Types.type_for("xml").first} }
          it "has 1 xml parent when filtered by Mime::Type['xml']" do
            expect(parents_paths).to match_array(["/vehicles/cars.xml", nil, nil])
          end
          it "has 1 xml parent" do
            expect(parent_path).to eql("/vehicles/cars.xml")
          end
        end
        context ":all resources filter" do
          it "has 1 parent with 2 resources, 2 empty parents" do
            paths = subject.parents(type: :all).map do |nodes|
              nodes.map{ |n| n.request_path if n }
            end
            expect(paths).to eql([%w[/vehicles/cars.html /vehicles/cars.xml], [], []])
          end
          it "has parent" do
            expect(subject.parent(type: :all).map(&:request_path)).to eql(%w[/vehicles/cars.html /vehicles/cars.xml])
          end
        end
      end
      it "has siblings" do
        expect(subject.siblings.map(&:request_path)).to match_array(%w[/vehicles/cars/cierra.html /vehicles/cars/camry.html])
      end
      it "has children" do
        expect(subject.children.map(&:request_path)).to match_array(%w[/vehicles/cars/compacts/smart.html])
      end
    end
  end
end
