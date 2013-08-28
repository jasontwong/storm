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

    params[:include] = [] unless params[:include].is_a? Array
    
    render json: @member.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(params[:member])
    @member.salt = SecureRandom.hex
    password = Digest::SHA256.new
    password.update @member.password + @member.salt
    @member.password = password.hexdigest

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
      @member.parse_points(params[:points].to_f, params[:company_id])
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
      password = Digest::SHA256.new
      password.update params[:password] + @member.salt
      
      if password.hexdigest == @member.password
        render json: @member
      else
        render json: { member: 'Bad Password' }, status: :unprocessable_entity
      end
    else
      render json: { member: 'Not Found' }, status: :unprocessable_entity
    end

  end

  # POST /members/fb_verify
  # POST /members/fb_verify.json
  def fb_verify
    unless params[:email].nil?
      @member = Member.where(email: params[:email], fb_id: params[:fb_id]).first
    end

    @member ||= Member.where(fb_id: params[:fb_id]).first

    if @member
      render json: @member
    else
      render json: { member: 'Not Found' }, status: :unprocessable_entity
    end

  end

  # PUT /members/pass_reset
  # PUT /members/pass_reset.json
  def pass_reset
    members = Member.where(email: params[:email]).limit(1)
    if members.length == 1
      @member = members[0]
      password = Digest::SHA256.new
      password.update @member.to_json + @member.salt
      @member.temp_pass = password.hexdigest
      @member.temp_pass_expiration = Time.now.utc + 1.day
      
      if @member.save
        render json: @member
      else
        render json: @member.errors, status: :unprocessable_entity
      end
    else
      render json: { member: 'Not Found' }, status: :unprocessable_entity
    end

  end

  # GET /members/1/rewards
  # GET /members/1/rewards.json
  def reward_index
    @member_rewards = MemberReward.where(member_id: params[:id])

    render json: @member_rewards
  end

  # POST /members/1/rewards
  # POST /members/1/rewards.json
  def reward_create
    @member_reward = MemberReward.new(params[:member_reward])
    if @member_reward.reward.nil? 
      render json: ["that reward doesn't exist"], status: :unprocessable_entity
    elsif @member_reward.reward.expired? 
      render json: ["that reward is expired"], status: :unprocessable_entity
    elsif @member_reward.save
      # Look up the reward/company and figure out if it needs code or bcode
      # @member_reward.generate_code(MemberReward::ALPHANUMERIC, 5)
      render json: @member_reward, status: :created, location: @member_reward
    else
      render json: @member_reward.errors, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /members/1/rewards/1
  # PUT/PATCH /members/1/rewards/1.json
  def reward_update
    member = Member.find(params[:member_id])
    @member_reward = MemberReward.find(params[:id])
    if @member_reward.update_attributes(params[:member_reward])
      head :no_content
    else
      render json: @member_reward.errors, status: :unprocessable_entity
    end
  end
  
  # GET /members/1/points
  # GET /members/1/points.json
  def point_index
    where = {
      member_id: params[:id]
    }
    unless params[:company_id].nil?
      where[:company_id] = params[:company_id]
      @member_points = MemberPoints.where(where).first_or_create
    end

    @member_points ||= MemberPoints.where(where)

    render json: @member_points
  end

end
