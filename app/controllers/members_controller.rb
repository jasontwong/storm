class MembersController < ApplicationController
  # GET /members
  # GET /members.json
  def index
    @members = Member.all

    render json: @members
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @member = Member.find(params[:id])

    render json: @member
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(params[:member])

    if !@member.email.nil? && @member.save
      @member.parse_attrs(params[:attrs]) unless params[:attrs].nil?
      render json: @member, status: :created, location: @member
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    @member = Member.find(params[:id])
    @member.parse_attrs(params[:attrs]) unless params[:attrs].nil?
    @member.parse_answers(params[:answers]) unless params[:answers].nil?
    if !params[:points].nil? && !params[:company_id].nil?
      # TODO this should convert to decimal, not integer
      @member.parse_points(params[:points].to_i, params[:company_id])
    end

    if !@member.email.nil? && @member.update_attributes(params[:member])
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member = Member.find(params[:id])
    @member.active = false

    if @member.save
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # POST /members/verify
  # POST /members/verify.json
  def verify
    members = Member.where(email: params[:email]).limit(1)
    if members.length == 1
      @member = members[0]
      password = params[:password] + @member.salt

      if password == BCrypt::Password.new(@member.password)
        render json: @member
      else
        render json: { member: 'Bad Password' }, status: :not_acceptable
      end
    else
      render json: { member: 'Not Found' }, status: :not_acceptable
    end

  end

  # GET /members/1/reward
  # GET /members/1/reward.json
  def reward_index
    @member_rewards = MemberReward.where(member_id: params[:id])

    render json: @member_rewards
  end

  # POST /members/1/reward
  # POST /members/1/reward.json
  def reward_create
    member = Member.find(params[:id])
    @member_reward = MemberReward.new(redeemed: false)
    @member_reward.reward = Reward.find(params[:reward_id])
    @member_reward.member = member
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

  # PUT/PATCH /members/1/reward/1
  # PUT/PATCH /members/1/reward/1.json
  def reward_update
    member = Member.find(params[:member_id])
    @member_reward = MemberReward.find(params[:id])
    if @member_reward.redeemed_time.nil?
      @member_reward.rewarded_time = Time.now
      if @member_reward.update_attributes(params[:member_reward])
        render json: @member_reward, status: :created, location: @member_reward
      else
        render json: @member_reward.errors, status: :unprocessable_entity
      end
    else
      render json: ["that reward has already been rewarded"], status: :unprocessable_entity
    end
  end
end
