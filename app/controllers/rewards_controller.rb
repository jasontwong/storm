class RewardsController < ApplicationController
  # GET /rewards
  # GET /rewards.json
  def index
    unless params[:company_id].nil?
      @rewards = Reward.where(company_id: params[:company_id])
    end
    @rewards ||= Reward.all

    render json: @rewards
  end

  # GET /rewards/1
  # GET /rewards/1.json
  def show
    @reward = Reward.find(params[:id])

    render json: @reward
  end

  # POST /rewards
  # POST /rewards.json
  def create
    @reward = Reward.new(params[:reward])

    if @reward.save
      log = Changelog.where(
        model: 'Reward', 
        model_id: @reward.id,
      ).first_or_create!
      log.model_action = 'create'
      log.save
      render json: @reward, status: :created, location: @reward
    else
      render json: @reward.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /rewards/1
  # PATCH/PUT /rewards/1.json
  def update
    @reward = Reward.find(params[:id])

    if @reward.update_attributes(params[:reward])
      log = Changelog.where(
        model: 'Reward', 
        model_id: @reward.id,
      ).first_or_create!
      log.model_action = 'update'
      log.save
      head :no_content
    else
      render json: @reward.errors, status: :unprocessable_entity
    end
  end

  # DELETE /rewards/1
  # DELETE /rewards/1.json
  def destroy
    @reward = Reward.find(params[:id])
    @reward.destroy

    log = Changelog.where(
      model: 'Reward', 
      model_id: @reward.id,
    ).first_or_create!
    log.model_action = 'destroy'
    log.save

    head :no_content
  end
end
