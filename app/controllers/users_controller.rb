class UsersController < ApplicationController
  before_action :authorize
  before_action :is_admin?, only: %i[index show deactivate activate]
  before_action :set_user, only: %i[show deactivate activate]
  before_action :set_accesses, only: %i[show deactivate]

  def index
    search_params = params.permit(:format, :page, q: [:displayname_cont, :s])
    @q = User.select(:id, :displayname).where(is_active: true).order(displayname: :asc).ransack(search_params[:q])
    users = @q.result
    @pagy, @users = pagy_countless(users, items: 50)
  end

  def show
  end

  def deactivate
    if @user.update(is_deactivated: true)
      flash[:success] = "Deactivated"
      if @accesses.present?
        @accesses.each do |access|
          AuditLog.create(
            system_id:          access.role.system.id,
            event_type:         :access_revoked,
            event_description:  "Access revoked due to force deactivation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
          role = access.role # for Trigger IAM job
          access.destroy
          TriggerIamJob.perform_later(role)
        end
      end
    end
    redirect_to user_path
  end

  def activate
    if @user.update(is_deactivated: false)
      flash[:success] = "Activated"
    end
    redirect_to user_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_accesses
    @accesses = Access.where(user_id: params[:id]).joins(:role).order(approved: :asc, created_at: :desc)
  end

end