class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_filter :authenticate_token

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: 'Record Not Found', status: :not_found
  end

  private

  def authenticate_token
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

end
