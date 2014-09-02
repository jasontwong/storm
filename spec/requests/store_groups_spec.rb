require 'rails_helper'

RSpec.describe "StoreGroups", :type => :request do
  describe "GET /store_groups" do
    it "works! (now write some real specs)" do
      get store_groups_path
      expect(response.status).to be(200)
    end
  end
end
