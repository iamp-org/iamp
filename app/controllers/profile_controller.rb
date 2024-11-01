class ProfileController < ApplicationController
  before_action :authorize
  before_action :set_access_requests, only: %i[index]
  before_action :set_accesses, only: %i[index]
  before_action :set_sa_accesses, only: %i[index]

  def index
  end

  private

  def set_accesses
    # all access roles for current_user
    @accesses = Access.where(user: current_user).joins(:role).order(approved: :asc, created_at: :desc)
  end

  def set_sa_accesses
    # all access roles for service accounts managed by current_user
    @sa_accesses = Access.joins(:user).where("is_service = ? AND manager_id = ?", true, current_user.id).joins(:role).order(approved: :asc, created_at: :desc)
  end

  def set_access_requests
    # all access requests pending approval from current_user
    jsonb_query = (1..3).map { |i| "roles.approval_workflow_properties->'list#{i}' ? :approver_id" }.join(' OR ')
    @requests = Access.where.not("'#{current_user.id}' = ANY(approvals)").where(approved: false).joins(:role).where(jsonb_query, approver_id: current_user.id)
  end
end