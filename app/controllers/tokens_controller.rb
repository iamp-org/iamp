# app/controllers/tokens_controller.rb
class TokensController < ApplicationController
  before_action :authorize
  before_action :is_admin?
  before_action :set_token, only: %i[destroy]

  def index
    @tokens = Token.includes(:user).order(created_at: :desc)
  end

  def new
    @users = User.where(is_active: true)
  end

  def create
    user = User.find(params[:user_id])
    token = Token.generate_token(user)

    flash[:success] = token
    redirect_to tokens_path
  end


  def destroy
    if @token.destroy
      flash[:success] = "Deleted"
      redirect_to tokens_path
    else
      flash[:errors] = @token.errors.full_messages
      redirect_to tokens_path
    end
  end

  private

  def set_token
    @token = Token.find(params[:id])
  end
end
