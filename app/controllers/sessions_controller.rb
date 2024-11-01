class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token if Rails.env.development? # remove after https://github.com/omniauth/omniauth/pull/1106

	def new
    @maintainer_email = ENV.fetch("MAINTAINER_EMAIL") { "team@example.com" }
    if ENV.fetch("AUTH_METHOD") == "sso"
      repost('/auth/openid_connect', options: {authenticity_token: :auto})
    else 
      render template: "sessions/#{auth_method}"
    end
  end

  def create
    case auth_method
    when "ldap"
      user = auth_ldap
      if user.present?
        create_session(user)
      else
        flash[:warning] = "Authentication failed"
        redirect_to login_path
      end
    when "sso" # TODO: probably remove this due to auto SSO
      user = auth_sso
      if user.present?
        create_session(user)
      else
        flash[:warning] = "Authentication failed"
        redirect_to login_path
      end
    when "noauth"
      user = auth_noauth
      if user.present?
        create_session(user)
      else
        flash[:warning] = "Authentication failed"
        redirect_to login_path
      end
    end
	end

  def failure
    # flash[:error] = "Authentication failed: #{params[:message]}"
    redirect_to login_path
  end

	def destroy
		reset_session
		redirect_to login_path
	end

  private

  def auth_method
    # Supported values: noauth, ldap, sso
    ENV.fetch("AUTH_METHOD") { "ldap" }
  end

  def auth_ldap
    ldap = LdapService.new(
      Rails.application.config.ldap_host, 
      Rails.application.config.ldap_port,
      Rails.application.config.ldap_base
      )
    if ldap.authenticate("corp\\#{params[:username]}", params[:password])
      user = User.find_by(username: params[:username].downcase)
    end
  end

  def auth_sso
    auth = request.env['omniauth.auth']
    user = User.find_by(id: auth.uid) # uid corresponds to sub claim
  end

  def auth_noauth
    auth = request.env['omniauth.auth']
    user = User.find_by(username: auth.info.name.downcase)
  end

  def create_session(user)
    session[:user_id] = user.id
		session[:expires_at] = Time.current + 12.hours
    requested_path = session[:requested_path] || root_path
    session[:requested_path] = nil # Clear the stored path from the session
    redirect_to requested_path
  end

end