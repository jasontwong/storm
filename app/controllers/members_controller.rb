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
end
