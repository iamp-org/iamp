class Api::V1::Users::SshkeysController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :auth_from_token
  before_action :set_user

  # GET /api/v1/users/:id/sshkeys
  def show
    if @user.present?
      if @user.sshkey.present?
        render json: { data: @user.sshkey }
      else
        render json: { error: 'SSH key not found' }, status: :not_found
      end
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  # POST /api/v1/users/:id/sshkeys
  def create
    if @user.present?
      attestation_service = PivAttestationService.new(params[:attestation_certificate], params[:attestation_statement])
      result, status = attestation_service.perform_attestation(@user)

      render json: result, status: status
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # DELETE /api/v1/users/:id/sshkeys
  def destroy
    if @user.present? && @user.update(sshkey: "")
      render json: { data: '' }, status: :ok
    else
      render json: { error: 'Something went wrong' }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
  end

end
