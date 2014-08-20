class IosController < ApplicationController
  # POST /ios/check_version
  # POST /ios/check_version.json
  def check_version
    render json: { success: params[:version].to_f >= 2.0 }
  end
end
