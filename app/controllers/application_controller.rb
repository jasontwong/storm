class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_filter :authenticate_token

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: e.inspect.to_s, status: 404
  end

  private

  def authenticate_token
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

end
