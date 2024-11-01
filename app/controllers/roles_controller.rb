class RolesController < ApplicationController
  before_action :authorize
  before_action :is_allowed_to_edit?, only: %i[edit update destroy]
  before_action :is_allowed_to_view?, only: %i[show]
  before_action :set_role, only: %i[show edit update destroy]
  before_action :set_accesses, only: %i[show]
  before_action :set_approval_workflow_options, only: %i[new create edit update]
  before_action :set_autodenial_workflow_options, only: %i[new create edit update]
  before_action :set_autoapproval_workflow_options, only: %i[new create edit update]
  before_action :set_provision_workflow_options, only: %i[new create edit update]
  before_action :set_system_options, only: %i[new create edit update]
  before_action :set_user_options, only: %i[new create edit update]

  def index
    search_params = params.permit(:format, :page, q: [:name_or_system_name_cont, :s])
    @q = Role.select(:id, :name, :system_id, :is_active).order(system_id: :asc).ransack(search_params[:q])
    roles = @q.result
    @pagy, @roles = pagy_countless(roles, items: 50)
  end

  def show
    # in role details we search over accesses
    search_params = params.permit(:id, :format, :page, q: [:user_displayname_cont, :s])
    @q = Access.where(role_id: params[:id]).ransack(search_params[:q])
    accesses = @q.result
    @pagy, @accesses = pagy_countless(accesses, items: 50)
  end
    
  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      AuditLog.create(
        user_id:            current_user.id,
        system_id:          @role.system.id,
        event_type:         :role_created,
        event_description:  "Access role created by #{current_user.displayname}. System: #{@role.system.name}. Role: #{@role.name}"
      )
      flash[:success] = "Created"
      render turbo_stream: turbo_stream.action(:redirect, role_path(@role))
    else
      flash.now[:errors] = @role.errors.full_messages
      render :new
    end
  end

  def update
    if @role.update(role_params.merge(is_active: true))
      AuditLog.create(
        user_id:            current_user.id,
        system_id:          @role.system.id,
        event_type:         :role_updated,
        event_description:  "Access role updated by #{current_user.displayname}. System: #{@role.system.name}. Role: #{@role.name}"
      )
      flash[:success] = "Saved"
      render turbo_stream: turbo_stream.action(:redirect, role_path(@role))
    else
      flash.now[:errors] = @role.errors.full_messages
      render :edit
    end
  end

  def destroy
    if @role.destroy
      AuditLog.create(
        user_id:            current_user.id,
        system_id:          @role.system.id,
        event_type:         :role_removed,
        event_description:  "Access role removed by #{current_user.displayname}. System: #{@role.system.name}. Role: #{@role.name}"
      )
      flash[:success] = "Deleted"
      redirect_to roles_path
    else
      flash[:errors] = @role.errors.full_messages
      redirect_to role_path
    end
  end

  private

  def is_allowed_to_edit?
    role = Role.find(params[:id])
    if !current_user.is_admin && !system_allowed_for_user?(role.system_id)
      flash[:warning] = "Not authorized"
      redirect_to roles_path
    end
  end

  def is_allowed_to_view?
    role = Role.find(params[:id])
    approvers = AccessApprovalService.get_approvers(role)
    if approvers.none? { |user| user.id == current_user.id } && !current_user.is_admin && !system_allowed_for_user?(role.system_id)
      flash[:warning] = "Not authorized"
      redirect_to roles_path
    end
  end

  def systems_for_current_user
    if current_user.is_admin?
      System.all
    else
      current_user.systems
    end
  end

  def system_allowed_for_user?(system_id)
    if current_user.is_admin?
      true
    else
      current_user.systems.exists?(id: system_id)
    end
  end

  def set_role
    @role = Role.find(params[:id])
  end

  def set_accesses
    @accesses = Access.where(role_id: params[:id])
  end

  def set_user_options
    @user_options = User.where(is_active: true, is_service: false).select(:id, :displayname) #User.all.map { |user| [user.displayname, user.id] }
  end

  def set_system_options
    @system_options = systems_for_current_user.map { |system| [system.name, system.id] }
  end

  def set_approval_workflow_options
    @approval_workflow_options = ApprovalWorkflow.all.map { |workflow| [workflow.name, workflow.id] }
  end

  def set_autodenial_workflow_options
    @autodenial_workflow_options = AutodenialWorkflow.all.map { |workflow| [workflow.name, workflow.id] }
  end

  def set_autoapproval_workflow_options
    @autoapproval_workflow_options = AutoapprovalWorkflow.all.map { |workflow| [workflow.name, workflow.id] }
  end

  def set_provision_workflow_options
    @provision_workflow_options = ProvisionWorkflow.all.map { |workflow| [workflow.name, workflow.id] }
  end

  def role_params
    params.require(:role).permit(:name, :system_id, :term, :approval_workflow_id, :provision_workflow_id, :autoapproval_workflow_id, :autodenial_workflow_id,
                                  approval_workflow_properties: {}, provision_workflow_properties: {}, autoapproval_workflow_properties: {}, autodenial_workflow_properties: {})
  end
end