require "rails_helper"

RSpec.describe StoreGroupsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/store_groups").to route_to("store_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/store_groups/new").to route_to("store_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/store_groups/1").to route_to("store_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/store_groups/1/edit").to route_to("store_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/store_groups").to route_to("store_groups#create")
    end

    it "routes to #update" do
      expect(:put => "/store_groups/1").to route_to("store_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/store_groups/1").to route_to("store_groups#destroy", :id => "1")
    end

  end
end
