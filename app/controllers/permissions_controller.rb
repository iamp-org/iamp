class PermissionsController < ApplicationController
  before_action :authorize
  before_action :is_admin?
  before_action :set_permission, only: %i[destroy]

  def index
    search_params = params.permit(:format, :page, q: [:user_or_system_cont, :s])
    @q = Permission.all.order(created_at: :desc).ransack(search_params[:q])
    permissions = @q.result
    @pagy, @permissions = pagy_countless(permissions, items: 50)
  end

  def new
    @systems = System.all
    @users = User.where(is_active: true, is_service: false)
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      flash[:success] = "Created"
      redirect_to permissions_path
    else
      flash[:errors] = @permission.errors.full_messages
      redirect_to permissions_path
    end
  end

  def destroy
    if @permission.destroy
      flash[:success] = "Deleted"
      redirect_to permissions_path
    else
      flash[:errors] = @permission.errors.full_messages
      redirect_to permissions_path
    end
  end

  private

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_params
    params.require(:permission).permit(:user_id, :system_id)
  end
end