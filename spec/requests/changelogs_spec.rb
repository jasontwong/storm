require 'spec_helper'

describe "Changelogs" do
  describe "GET /changelogs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get changelogs_path
      response.status.should be(200)
    end
  end
end
