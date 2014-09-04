class IosController < ApplicationController
  # {{{ def check_version
  # POST /ios/check_version
  # POST /ios/check_version.json
  def check_version
    render json: { success: params[:version].to_f >= 2.0 }
  end

  # }}}
  # {{{ def incomplete_surveys
  # POST /ios/:member_id/incomplete_surveys
  # POST /ios/:member_id/incomplete_surveys.json
  def incomplete_surveys
    # expiration constraints
    #   - incomplete survey
    #   - > 5 days old

    surveys = MemberSurvey.where(member_id: params[:member_id], completed: false, created_at: 7.days.ago..Time.now)
    render json: surveys
  end

  # }}}
end
