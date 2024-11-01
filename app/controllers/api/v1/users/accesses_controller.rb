class Api::V1::Users::AccessesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :auth_from_token
  before_action :set_user

  # GET /api/v1/users/:id/accesses
  def show
    if @user.present?
      @accesses = Access.where(user_id: @user.id)
      render json: @accesses,
              only: [:id, :expires_at, :approved],
              include: { 
                role: { 
                  only: [:id, :name],
                  include: { system: { only: [:id, :name] } }
                }
              }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  # POST /api/v1/users/:id/accesses
  def create
    if @user.present?
      if @user.is_deactivated
        render json: { error: "The user is deactivated" }, status: :unprocessable_entity
      else
        @access = Access.new(access_attributes.merge(user_id: @user.id))
        if AccessAutodenialService.handle_autodenial(@access)
          render json: { error: "Declined by automation" }, status: :unprocessable_entity
        elsif @access.save
          UserMailer.access_requested(@access).deliver_later
          if @access.role.autoapproval_workflow.present?
            AccessAutoapprovalService.handle_autoapproval(@access)
          else
            UserMailer.access_pending_approval(@access).deliver_later
          end
          render json: @access, status: :accepted
        else
          render json: { error: "The role has already been taken" }, status: :unprocessable_entity
        end
      end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def access_attributes
    params.permit(
      :role_id, :justification, :requestor_id
    )
  end

end
