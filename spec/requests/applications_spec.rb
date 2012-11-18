require 'spec_helper'

describe "Applications" do
  let(:user) { FactoryGirl.create(:user) }
  let(:datacenter) { FactoryGirl.create(:datacenter) }
  let(:foreign_datacenter) { FactoryGirl.create(:datacenter, name: "Berlin") }

  before do
    login_as user
    @app = Application.create!(name: "app-01")
    Application.create!(name: "app-03")
    Application.create!(name: "app-02")
    ApplicationInstance.create!(name: "prod", authentication_method: "none", application_id: @app.id)
    Role.create(name: "Developer")
  end

  describe "GET /applications" do
    it "gets all applications ordered by name" do
      get applications_path
      response.status.should be 200
      response.body.should include "app-01"
    end

    it "only sees applications in visible_datacenters or without datacenter" do
      user.update_attribute(:visible_datacenter_ids, [datacenter.id])
      Application.create!(name: "app-04", datacenter_ids: [foreign_datacenter.id])
      visit applications_path
      page.status_code.should be 200
      page.should have_content "app-01"     #no datacenter
      page.should_not have_content "app-04" #datacenter, not visible
    end
  end

  describe "GET /applications/:id" do
    it "shows an application page" do
      get application_path(@app)
      response.body.should have_selector "h2", content: "Application app-01"
    end
  end

  describe "GET /applications/:id/edit" do
    it "shows an application form" do
      get edit_application_path(@app)
      response.body.should have_selector "form", id: "edit_application"
    end
  end
end
