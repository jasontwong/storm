class ClientsController < ApplicationController
  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.all

    render json: @clients
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])

    render json: @client
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    if @client.save
      render json: @client, status: :created, location: @client
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    if @client.update_attributes(params[:client])
      head :no_content
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.active = false

    if @client.save
      head :no_content
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end
end
