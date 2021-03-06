require "spec_helper"

describe Sitepress::SiteController, type: :controller do
  context "templated page" do
    render_views
    before { get :show, resource_path: "/time" }
    let(:resource) { Sitepress.site.get("/time") }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Tick tock, tick tock</h1>")
    end
    it "renders layout" do
      expect(response.body).to include("<title>Test layout</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to eql("text/html")
    end
    context "helper methods" do
      subject { @controller }
      it "#current_page" do
        expect(subject.send(:current_page).asset.path).to eql(resource.asset.path)
      end
      it "#site" do
        expect(subject.send(:site)).to eql(Sitepress.site)
      end
    end
  end

  context "static page" do
    render_views
    before { get :show, resource_path: "/hi" }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Hi!</h1>")
    end
    it "renders layout" do
      expect(response.body).to include("<title>Dummy</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to eql("text/html")
    end
  end

  context "non-existent page" do
    it "is status 404" do
      expect {
        get :show, resource_path: "/non-existent"
      }.to raise_exception(ActionController::RoutingError)
    end
  end
end
