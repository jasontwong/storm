require "spec_helper"

describe ChangelogsController do
  describe "routing" do

    it "routes to #index" do
      get("/changelogs").should route_to("changelogs#index")
    end

    it "routes to #new" do
      get("/changelogs/new").should route_to("changelogs#new")
    end

    it "routes to #show" do
      get("/changelogs/1").should route_to("changelogs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/changelogs/1/edit").should route_to("changelogs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/changelogs").should route_to("changelogs#create")
    end

    it "routes to #update" do
      put("/changelogs/1").should route_to("changelogs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/changelogs/1").should route_to("changelogs#destroy", :id => "1")
    end

  end
end
