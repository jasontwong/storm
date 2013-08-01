class ChangelogsController < ApplicationController
  # GET /changelogs
  # GET /changelogs.json
  def index
    @changelogs = Changelog.order('created_at ASC')

    if params[:date]
      @changelogs = @changelogs.where('created_at > ?', params[:date])
    else
      @changelogs = @changelogs.all
    end

    render json: @changelogs
  end

  # GET /changelogs/1
  # GET /changelogs/1.json
  def show
    @changelog = Changelog.find(params[:id])

    render json: @changelog
  end

  # POST /changelogs
  # POST /changelogs.json
  def create
    @changelog = Changelog.new(params[:changelog])

    if @changelog.save
      render json: @changelog, status: :created, location: @changelog
    else
      render json: @changelog.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /changelogs/1
  # PATCH/PUT /changelogs/1.json
  def update
    @changelog = Changelog.find(params[:id])

    if @changelog.update_attributes(params[:changelog])
      head :no_content
    else
      render json: @changelog.errors, status: :unprocessable_entity
    end
  end

  # DELETE /changelogs/1
  # DELETE /changelogs/1.json
  def destroy
    @changelog = Changelog.find(params[:id])
    @changelog.destroy

    head :no_content
  end
end
