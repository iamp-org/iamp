class Api::V1::RolesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :auth_from_token
  before_action :set_role, only: %i[show update destroy]

  # GET /api/v1/roles/:id
  def show
    if @role.present?
      render json: @role
    else
      render json: { error: 'Role not found' }, status: :not_found
    end
  end

  # POST /api/v1/roles
  def create
    role = Role.new(role_attributes)

    if role.save
      render json: role, status: :created
    else
      render json: { errors: role.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/roles/:id
  def update
    if @role.update(role_attributes)
      render json: @role, status: :ok
    else
      render json: { errors: @role.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/roles/:id
  def destroy
    if @role.destroy
      render json: { message: "Role deleted successfully" }, status: :ok
    else
      render json: { errors: @role.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_attributes
    params.permit(
      :name, 
      :system_id, 
      :term, 
      :approval_workflow_id, 
      :autoapproval_workflow_id, 
      :provision_workflow_id, 
      :is_active, 
      :autodenial_workflow_id,
      approval_workflow_properties: { list1: [] },
      provision_workflow_properties: { list1: [] },
      autoapproval_workflow_properties: {},
      autodenial_workflow_properties: {}
    )
  end

end
