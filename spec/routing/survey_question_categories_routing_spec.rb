require "spec_helper"

describe SurveyQuestionCategoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/survey_question_categories").should route_to("survey_question_categories#index")
    end

    it "routes to #new" do
      get("/survey_question_categories/new").should route_to("survey_question_categories#new")
    end

    it "routes to #show" do
      get("/survey_question_categories/1").should route_to("survey_question_categories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/survey_question_categories/1/edit").should route_to("survey_question_categories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/survey_question_categories").should route_to("survey_question_categories#create")
    end

    it "routes to #update" do
      put("/survey_question_categories/1").should route_to("survey_question_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/survey_question_categories/1").should route_to("survey_question_categories#destroy", :id => "1")
    end

  end
end
