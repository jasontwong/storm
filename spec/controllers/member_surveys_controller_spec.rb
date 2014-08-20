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

describe MemberSurveysController do

  # This should return the minimal set of attributes required to create a valid
  # MemberSurvey. As you add validations to MemberSurvey, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MemberSurveysController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all member_surveys as @member_surveys" do
      member_survey = MemberSurvey.create! valid_attributes
      get :index, {}, valid_session
      assigns(:member_surveys).should eq([member_survey])
    end
  end

  describe "GET show" do
    it "assigns the requested member_survey as @member_survey" do
      member_survey = MemberSurvey.create! valid_attributes
      get :show, {:id => member_survey.to_param}, valid_session
      assigns(:member_survey).should eq(member_survey)
    end
  end

  describe "GET new" do
    it "assigns a new member_survey as @member_survey" do
      get :new, {}, valid_session
      assigns(:member_survey).should be_a_new(MemberSurvey)
    end
  end

  describe "GET edit" do
    it "assigns the requested member_survey as @member_survey" do
      member_survey = MemberSurvey.create! valid_attributes
      get :edit, {:id => member_survey.to_param}, valid_session
      assigns(:member_survey).should eq(member_survey)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new MemberSurvey" do
        expect {
          post :create, {:member_survey => valid_attributes}, valid_session
        }.to change(MemberSurvey, :count).by(1)
      end

      it "assigns a newly created member_survey as @member_survey" do
        post :create, {:member_survey => valid_attributes}, valid_session
        assigns(:member_survey).should be_a(MemberSurvey)
        assigns(:member_survey).should be_persisted
      end

      it "redirects to the created member_survey" do
        post :create, {:member_survey => valid_attributes}, valid_session
        response.should redirect_to(MemberSurvey.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved member_survey as @member_survey" do
        # Trigger the behavior that occurs when invalid params are submitted
        MemberSurvey.any_instance.stub(:save).and_return(false)
        post :create, {:member_survey => {  }}, valid_session
        assigns(:member_survey).should be_a_new(MemberSurvey)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        MemberSurvey.any_instance.stub(:save).and_return(false)
        post :create, {:member_survey => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested member_survey" do
        member_survey = MemberSurvey.create! valid_attributes
        # Assuming there are no other member_surveys in the database, this
        # specifies that the MemberSurvey created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        MemberSurvey.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => member_survey.to_param, :member_survey => { "these" => "params" }}, valid_session
      end

      it "assigns the requested member_survey as @member_survey" do
        member_survey = MemberSurvey.create! valid_attributes
        put :update, {:id => member_survey.to_param, :member_survey => valid_attributes}, valid_session
        assigns(:member_survey).should eq(member_survey)
      end

      it "redirects to the member_survey" do
        member_survey = MemberSurvey.create! valid_attributes
        put :update, {:id => member_survey.to_param, :member_survey => valid_attributes}, valid_session
        response.should redirect_to(member_survey)
      end
    end

    describe "with invalid params" do
      it "assigns the member_survey as @member_survey" do
        member_survey = MemberSurvey.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        MemberSurvey.any_instance.stub(:save).and_return(false)
        put :update, {:id => member_survey.to_param, :member_survey => {  }}, valid_session
        assigns(:member_survey).should eq(member_survey)
      end

      it "re-renders the 'edit' template" do
        member_survey = MemberSurvey.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        MemberSurvey.any_instance.stub(:save).and_return(false)
        put :update, {:id => member_survey.to_param, :member_survey => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested member_survey" do
      member_survey = MemberSurvey.create! valid_attributes
      expect {
        delete :destroy, {:id => member_survey.to_param}, valid_session
      }.to change(MemberSurvey, :count).by(-1)
    end

    it "redirects to the member_surveys list" do
      member_survey = MemberSurvey.create! valid_attributes
      delete :destroy, {:id => member_survey.to_param}, valid_session
      response.should redirect_to(member_surveys_url)
    end
  end

end
