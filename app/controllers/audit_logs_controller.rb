class AuditLogsController < ApplicationController
  before_action :authorize
  before_action :load_user_permissions, only: %i[index]
  before_action :is_permitted_to_view?, only: %i[index]

  def index
    # For non-admin the audit logs are restricted to permitted systems
    search_params = params.permit(:format, :page, q: [:event_description_cont, :s])

    if current_user.is_admin?
      @q = AuditLog.all.order(created_at: :desc).ransack(search_params[:q])
    else
      user_permission_system_ids = @user_permissions&.pluck(:system_id)
      @q = AuditLog.where(system_id: user_permission_system_ids)
                   .order(created_at: :desc).ransack(search_params[:q])
    end

    audit_logs = @q.result
    @pagy, @audit_logs = pagy_countless(audit_logs, items: 50)
  end

  private

  def load_user_permissions
    @user_permissions = Permission.where(user_id: current_user.id)
  end

  def is_permitted_to_view?
    @user_permissions = load_user_permissions
    if !current_user.is_admin && @user_permissions.empty?
      flash[:warning] = "Not authorized"
      redirect_to root_path
    end
  end

end

