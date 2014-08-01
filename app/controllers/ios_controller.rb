class IosController < ApplicationController
  # POST /ios/check_version
  # POST /ios/check_version.json
  def check_version
    render json: { success: params[:version].to_f >= (ENV['MIN_IOS_VERSION'] || 1.5).to_f }
  end
end
