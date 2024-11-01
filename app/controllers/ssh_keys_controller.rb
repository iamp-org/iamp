class SshKeysController < ApplicationController
  before_action :authorize

  def new
  end

  def create
    if params[:attestation_certificate].present? && params[:attestation_statement].present?
      attestation_certificate   = params[:attestation_certificate].tempfile.read
      attestation_statement     = params[:attestation_statement].tempfile.read
      user                      = current_user

      attestation_service = PivAttestationService.new(attestation_certificate, attestation_statement)
      result, status = attestation_service.perform_attestation(user)

      if status == :accepted
        flash[:success] = "SSH key successfully uploaded"
        redirect_to ssh_preferences_path
      else
        flash[:errors] = Array(result[:error] || 'Unknown error')
        redirect_to ssh_preferences_path
      end
    else
      flash[:errors] = ["PEM encoded certificates must be provided"]
      redirect_to ssh_preferences_path
    end
  end

  def destroy
    if current_user.update(sshkey: "")
      flash[:success] = "SSH key removed"
      redirect_to ssh_preferences_path
    else
      flash[:errors] = ["Unknown error"]
      redirect_to ssh_preferences_path
    end
  end

end