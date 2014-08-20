require "rails_helper"

describe MemberSurveyAnswersController do
  describe "routing" do

    it "routes to #index" do
      get("/member_survey_answers").should route_to("member_survey_answers#index")
    end

    it "routes to #new" do
      get("/member_survey_answers/new").should route_to("member_survey_answers#new")
    end

    it "routes to #show" do
      get("/member_survey_answers/1").should route_to("member_survey_answers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/member_survey_answers/1/edit").should route_to("member_survey_answers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/member_survey_answers").should route_to("member_survey_answers#create")
    end

    it "routes to #update" do
      put("/member_survey_answers/1").should route_to("member_survey_answers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/member_survey_answers/1").should route_to("member_survey_answers#destroy", :id => "1")
    end

  end
end
