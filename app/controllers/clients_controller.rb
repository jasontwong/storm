class ClientsController < ApplicationController
  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @clients.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @client.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    @client.stores = Store.where(id: params[:store_ids]) if params[:store_ids].present?

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

    @client.stores = Store.where(id: params[:store_ids]) if params[:store_ids].present?

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
  
  # POST /clients/verify
  # POST /clients/verify.json
  def verify
    @client = Client.where(email: params[:email]).limit(1).first
    unless @client.nil?
      password = Digest::SHA256.new
      password.update params[:password] + @client.salt
      
      if password.hexdigest == @client.password
        @client.temp_password = nil unless @client.temp_password.nil?

        if @client.save
          head :no_content
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      else
        render json: { client: 'Bad Password' }, status: :unprocessable_entity
      end
    else
      render json: { client: 'Not Found' }, status: :unprocessable_entity
    end
  end

  # POST /clients/pass_generate
  # POST /clients/pass_generate.json
  def pass_generate
    @client = Client.where(email: params[:email]).limit(1).first

    unless @client.nil?
      password = Digest::SHA256.new
      password.update SecureRandom.hex + @client.salt

      @client.temp_password = password.hexdigest
      
      if @client.save
        ClientMailer.password_reset(@client).deliver
        render json: { temp_password: @client.temp_password }
      else
        render json: @client.errors, status: :unprocessable_entity
      end
    else
      render json: { client: 'Not Found' }, status: :unprocessable_entity
    end
  end

  # POST /clients/pass_reset
  # POST /clients/pass_reset.json
  def pass_reset
    @client = Client.where(temp_password: params[:temp_password]).limit(1).first
    @client = nil if @client.updated_at + 1.days < Time.now.utc

    unless @client.nil?
      password = Digest::SHA256.new
      password.update params[:password] + @client.salt

      @client.password = password.hexdigest
      @client.temp_password = nil
      
      if @client.save
        head :no_content
      else
        render json: @client.errors, status: :unprocessable_entity
      end
    else
      render json: { client: 'Not Found' }, status: :unprocessable_entity
    end
  end

end
