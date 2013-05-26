require "spec_helper"

describe SurveyQuestionsController do
  describe "routing" do

    it "routes to #index" do
      get("/survey_questions").should route_to("survey_questions#index")
    end

    it "routes to #new" do
      get("/survey_questions/new").should route_to("survey_questions#new")
    end

    it "routes to #show" do
      get("/survey_questions/1").should route_to("survey_questions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/survey_questions/1/edit").should route_to("survey_questions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/survey_questions").should route_to("survey_questions#create")
    end

    it "routes to #update" do
      put("/survey_questions/1").should route_to("survey_questions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/survey_questions/1").should route_to("survey_questions#destroy", :id => "1")
    end

  end
end
