class MembersController < ApplicationController
  # {{{ def index
  # GET /members
  # GET /members.json
  def index
    @members = Member.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @members.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # }}}
  # {{{ def show
  # GET /members/1
  # GET /members/1.json
  def show
    @member = Member.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array
    
    render json: @member.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # }}}
  # {{{ def create
  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)
    @member.salt = SecureRandom.hex
    password = Digest::SHA256.new
    password.update @member.password + @member.salt
    @member.password = password.hexdigest

    if @member.save
      @member.parse_attrs(params[:attrs]) unless params[:attrs].nil?
      render json: @member, status: :created, location: @member
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    @member = Member.find(params[:id])
    @member.parse_attrs(params[:attrs]) unless params[:attrs].nil?
    @member.parse_answers(params[:answers]) unless params[:answers].nil?
    if !params[:points].nil? && !params[:company_id].nil?
      @member.parse_points(params[:points].to_f, params[:company_id])
    end

    if @member.update_attributes!(member_params)
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def destroy
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

  # }}}
  # {{{ def verify
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

  # }}}
  # {{{ def fb_verify
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

  # }}}
  # {{{ def pass_reset
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

  # }}}
  # {{{ def point_index
  # GET /members/1/points
  # GET /members/1/points.json
  def point_index
    Member.find(params[:id])
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

  # }}}
  private
    # {{{ def member_params
    def member_params
      params.require(:member).permit(:points, :company_id, :password, :email, :salt, :fb_id, :temp_pass, :active)
    end

    # }}}
end
