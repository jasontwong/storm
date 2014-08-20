require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SurveyQuestionCategoriesController do

  # This should return the minimal set of attributes required to create a valid
  # SurveyQuestionCategory. As you add validations to SurveyQuestionCategory, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SurveyQuestionCategoriesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all survey_question_categories as @survey_question_categories" do
      survey_question_category = SurveyQuestionCategory.create! valid_attributes
      get :index, {}, valid_session
      assigns(:survey_question_categories).should eq([survey_question_category])
    end
  end

  describe "GET show" do
    it "assigns the requested survey_question_category as @survey_question_category" do
      survey_question_category = SurveyQuestionCategory.create! valid_attributes
      get :show, {:id => survey_question_category.to_param}, valid_session
      assigns(:survey_question_category).should eq(survey_question_category)
    end
  end

  describe "GET new" do
    it "assigns a new survey_question_category as @survey_question_category" do
      get :new, {}, valid_session
      assigns(:survey_question_category).should be_a_new(SurveyQuestionCategory)
    end
  end

  describe "GET edit" do
    it "assigns the requested survey_question_category as @survey_question_category" do
      survey_question_category = SurveyQuestionCategory.create! valid_attributes
      get :edit, {:id => survey_question_category.to_param}, valid_session
      assigns(:survey_question_category).should eq(survey_question_category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SurveyQuestionCategory" do
        expect {
          post :create, {:survey_question_category => valid_attributes}, valid_session
        }.to change(SurveyQuestionCategory, :count).by(1)
      end

      it "assigns a newly created survey_question_category as @survey_question_category" do
        post :create, {:survey_question_category => valid_attributes}, valid_session
        assigns(:survey_question_category).should be_a(SurveyQuestionCategory)
        assigns(:survey_question_category).should be_persisted
      end

      it "redirects to the created survey_question_category" do
        post :create, {:survey_question_category => valid_attributes}, valid_session
        response.should redirect_to(SurveyQuestionCategory.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved survey_question_category as @survey_question_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        SurveyQuestionCategory.any_instance.stub(:save).and_return(false)
        post :create, {:survey_question_category => {  }}, valid_session
        assigns(:survey_question_category).should be_a_new(SurveyQuestionCategory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SurveyQuestionCategory.any_instance.stub(:save).and_return(false)
        post :create, {:survey_question_category => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested survey_question_category" do
        survey_question_category = SurveyQuestionCategory.create! valid_attributes
        # Assuming there are no other survey_question_categories in the database, this
        # specifies that the SurveyQuestionCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SurveyQuestionCategory.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => survey_question_category.to_param, :survey_question_category => { "these" => "params" }}, valid_session
      end

      it "assigns the requested survey_question_category as @survey_question_category" do
        survey_question_category = SurveyQuestionCategory.create! valid_attributes
        put :update, {:id => survey_question_category.to_param, :survey_question_category => valid_attributes}, valid_session
        assigns(:survey_question_category).should eq(survey_question_category)
      end

      it "redirects to the survey_question_category" do
        survey_question_category = SurveyQuestionCategory.create! valid_attributes
        put :update, {:id => survey_question_category.to_param, :survey_question_category => valid_attributes}, valid_session
        response.should redirect_to(survey_question_category)
      end
    end

    describe "with invalid params" do
      it "assigns the survey_question_category as @survey_question_category" do
        survey_question_category = SurveyQuestionCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SurveyQuestionCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => survey_question_category.to_param, :survey_question_category => {  }}, valid_session
        assigns(:survey_question_category).should eq(survey_question_category)
      end

      it "re-renders the 'edit' template" do
        survey_question_category = SurveyQuestionCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SurveyQuestionCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => survey_question_category.to_param, :survey_question_category => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested survey_question_category" do
      survey_question_category = SurveyQuestionCategory.create! valid_attributes
      expect {
        delete :destroy, {:id => survey_question_category.to_param}, valid_session
      }.to change(SurveyQuestionCategory, :count).by(-1)
    end

    it "redirects to the survey_question_categories list" do
      survey_question_category = SurveyQuestionCategory.create! valid_attributes
      delete :destroy, {:id => survey_question_category.to_param}, valid_session
      response.should redirect_to(survey_question_categories_url)
    end
  end

end
