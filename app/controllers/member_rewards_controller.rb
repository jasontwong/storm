class MemberRewardsController < ApplicationController
  # {{{ def index 
  # GET /member_rewards
  # GET /member_rewards.json
  def index
    @member_rewards = MemberReward.where(member_id: params[:member_id])

    render json: @member_rewards
  end

  # }}}
  # {{{ def create
  # POST /member_rewards
  # POST /member_rewards.json
  def create
    @member_reward = MemberReward.new(member_reward_params)
    if @member_reward.reward.nil? 
      render json: ["that reward doesn't exist"], status: :unprocessable_entity
    elsif @member_reward.reward.expired? 
      render json: ["that reward is expired"], status: :unprocessable_entity
    elsif @member_reward.save
      render json: @member_reward, status: :created, location: @member_reward
    else
      render json: @member_reward.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PUT/PATCH /member_rewards/1
  # PUT/PATCH /member_rewards/1.json
  def update
    @member_reward = MemberReward.find(params[:id])
    if @member_reward.update_attributes!(member_reward_params)
      head :no_content
    else
      render json: @member_reward.errors, status: :unprocessable_entity
    end
  end
  
  # }}}
  private
    # {{{ def member_reward_params
    def member_reward_params
      params.require(:member_reward).permit(:member_id, :reward_id, :store_id, :redeemed, :printed, :scanned, :code, :bcode, :redeemed_time)
    end

    # }}}
end
