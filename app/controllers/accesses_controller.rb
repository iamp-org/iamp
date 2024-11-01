class AccessesController < ApplicationController
  before_action :authorize
  before_action :set_access, only: %i[comment approve destroy]
  before_action :set_system, only: %i[new create]
  before_action :set_service_accounts, only: %i[new create]
  before_action :set_subordinates, only: %i[new create]

  def new
    @access = Access.new
    @systems = System.joins(:roles).distinct
    @roles = Role.where(system_id: params[:system].presence)
  end

  def create
    if current_user.is_deactivated
      flash[:warning] = "The user is deactivated"
      redirect_to root_path
    else
      # user = params["user_id"].present? ? User.find(params["user_id"]) : current_user # TODO: validate if authorized?
      @access = Access.new(access_params.merge(requestor_id: current_user.id))
      if AccessAutodenialService.handle_autodenial(@access)
        flash[:errors] = ["Declined by automation"]
        redirect_to root_path
      elsif @access.save
        UserMailer.access_requested(@access).deliver_later
        if @access.role.autoapproval_workflow.present?
          AccessAutoapprovalService.handle_autoapproval(@access)
        else
          UserMailer.access_pending_approval(@access).deliver_later
        end
        flash[:success] = "Requested"
        redirect_to root_path
      else
        flash[:errors] = @access.errors.full_messages
        redirect_to root_path
      end

    end
  end

  def destroy
    comment = params[:access][:comment]
    access  = @access
    if request.referer.include?('roles')
      AuditLog.create(
        user_id:            current_user.id,
        system_id:          @access.role.system.id,
        event_type:         :access_revoked,
        event_description:  "Access revoked by #{current_user.displayname}. User: #{@access.user.displayname}. System: #{@access.role.system.name}. Role: #{@access.role.name}"
      )
      UserMailer.access_revoked(access, comment).deliver_later
    else
      AuditLog.create(
        user_id:            current_user.id,
        system_id:          @access.role.system.id,
        event_type:         :access_declined,
        event_description:  "Access request declined by #{current_user.displayname}. User: #{@access.user.displayname}. System: #{@access.role.system.name}. Role: #{@access.role.name}"
      )
      UserMailer.access_declined(access, comment).deliver_later
    end
    role = @access.role # for Trigger IAM job
    if @access.destroy
      TriggerIamJob.perform_later(role)
      flash[:success] = "Deleted"
      redirect_back(fallback_location: root_path)
    else
      flash[:errors] = @access.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def comment
  end

  def approve
    if @access.update(approvals: @access.approvals << current_user.id) # TODO: double check if current_user is allowed to approve
      AccessApprovalService.handle_approval(@access, current_user)
      flash[:success] = "Approved"
      redirect_to root_path
    else
      flash[:errors] = @access.errors.full_messages
      redirect_to root_path
    end
  end

  private

  def set_subordinates
    @subordinates = User.where(manager: current_user, is_service: false)
  end
  
  def set_service_accounts
    @service_accounts = User.where(manager: current_user, is_service: true)
  end
    
  def set_access
    @access = Access.find(params[:id])
  end

  def set_system
    @system = System.find_by(id: params[:system].presence)
  end

  def access_params
    params.require(:access).permit(:role_id, :user_id, :justification)
  end
end