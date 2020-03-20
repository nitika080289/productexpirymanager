class UsersController < ApplicationController
  # GET /user/:id
  def show
    @user = User.find(params[:id])
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      render json: @user
    else
      render error: { error: 'Unable to create user.' }, status: 400
    end
  end

end
