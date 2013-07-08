require "spec_helper"

describe MemberSurveysController do
  describe "routing" do

    it "routes to #index" do
      get("/member_surveys").should route_to("member_surveys#index")
    end

    it "routes to #new" do
      get("/member_surveys/new").should route_to("member_surveys#new")
    end

    it "routes to #show" do
      get("/member_surveys/1").should route_to("member_surveys#show", :id => "1")
    end

    it "routes to #edit" do
      get("/member_surveys/1/edit").should route_to("member_surveys#edit", :id => "1")
    end

    it "routes to #create" do
      post("/member_surveys").should route_to("member_surveys#create")
    end

    it "routes to #update" do
      put("/member_surveys/1").should route_to("member_surveys#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/member_surveys/1").should route_to("member_surveys#destroy", :id => "1")
    end

  end
end
