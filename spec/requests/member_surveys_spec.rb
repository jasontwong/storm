require 'rails_helper'

describe "MemberSurveys" do
  describe "GET /member_surveys" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get member_surveys_path
      response.status.should be(200)
    end
  end
end
