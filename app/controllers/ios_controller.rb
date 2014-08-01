class IosController < ApplicationController
  # POST /ios/check_version
  # POST /ios/check_version.json
  def check_version
    ENV['MIN_IOS_VERSION'] ||= '1.5'
    render json: { success: params[:version].to_f >= ENV['MIN_IOS_VERSION'].to_f }
  end
end
