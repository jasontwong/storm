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
    @member.parse_attrs(params[:attrs]) unless params[:attrs].nil?

    if @member.save
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

    if @member.update_attributes(params[:member])
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member = Member.find(params[:id])
    @member.destroy

    head :no_content
  end
end
