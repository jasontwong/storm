class MemberSurveysController < ApplicationController
  # GET /member_surveys
  # GET /member_surveys.json
  def index
    unless params[:store_id].nil?
      @member_surveys = MemberSurvey.where(store_id: params[:store_id])
    end

    unless params[:company_id].nil?
      @member_surveys ||= MemberSurvey.where(company_id: params[:company_id])
    end

    if params[:num_days] && !@member_surveys.nil?
      if params[:num_days] == 'today'
        @member_surveys = @member_surveys.where('created_at > ?', Time.now.strftime('%F'))
      else
        @member_surveys = @member_surveys.where('created_at > ?', Time.now.utc - params[:num_days].to_i.days)
      end
    end

    @member_surveys ||= MemberSurvey.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @member_surveys.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /member_surveys/1
  # GET /member_surveys/1.json
  def show
    # @member_survey = MemberSurvey.where(id: params[:id], store_id: params[:store_id])
    @member_survey = MemberSurvey.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    # render json: @member_survey.first.to_json(:include => params[:include].collect { |data| data.to_sym })
    render json: @member_survey.to_json(:include => { 
      :member_survey_answers => { 
        :include => { 
          :survey_question => {
            :only => [ :answer_type, :answer_meta ],
          },
        },
      }, 
      :company  => {},
    })
  end

  # POST /member_surveys
  # POST /member_surveys.json
  def create
    @member_survey = MemberSurvey.new(params[:member_survey])

    if @member_survey.save
      render json: @member_survey, status: :created, location: @member_survey
    else
      render json: @member_survey.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /member_surveys/1
  # PATCH/PUT /member_surveys/1.json
  def update
    @member_survey = MemberSurvey.find(params[:id])

    if @member_survey.update_attributes(params[:member_survey])
      head :no_content
    else
      render json: @member_survey.errors, status: :unprocessable_entity
    end
  end

  # DELETE /member_surveys/1
  # DELETE /member_surveys/1.json
  def destroy
    @member_survey = MemberSurvey.find(params[:id])
    @member_survey.destroy

    head :no_content
  end
end
