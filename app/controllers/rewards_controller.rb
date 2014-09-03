class RewardsController < ApplicationController
  # {{{ def index
  # GET /rewards
  # GET /rewards.json
  def index
    unless params[:company_id].nil?
      @rewards = Reward.where(company_id: params[:company_id])
    end
    @rewards ||= Reward.all

    render json: @rewards
  end

  # }}}
  # {{{ def show
  # GET /rewards/1
  # GET /rewards/1.json
  def show
    @reward = Reward.find(params[:id])

    render json: @reward
  end

  # }}}
  # {{{ def create
  # POST /rewards
  # POST /rewards.json
  def create
    @reward = Reward.new(reward_params)

    if @reward.save
      render json: @reward, status: :created, location: @reward
    else
      render json: @reward.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PATCH/PUT /rewards/1
  # PATCH/PUT /rewards/1.json
  def update
    @reward = Reward.find(params[:id])

    if @reward.update_attributes!(reward_params)
      head :no_content
    else
      render json: @reward.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def destroy
  # DELETE /rewards/1
  # DELETE /rewards/1.json
  def destroy
    @reward = Reward.find(params[:id])
    @reward.destroy

    head :no_content
  end
  
  # }}}
  private
    # {{{ def reward_params
    def reward_params
      params.require(:reward).permit(:store_group_id, :title, :description, :cost, :images)
    end

    # }}}
end
