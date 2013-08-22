class ApiKeyController < ApplicationController
  def generate
    @key = ApiKey.create!
    
    render json: @key
  end

end
