class ApplicationController < ActionController::Base
  include Pagy::Backend
  layout :layout_by_resource

  protected

  def current_user
    if session[:user_id] && session[:expires_at]
      if Time.now < session[:expires_at]
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end
    end
  end
  helper_method :current_user

  def authorize
    redirect_to '/login' unless current_user # GET BACK AFTER AUTO SSO IS IMPLEMENTED
  end

  def auth_from_token
    token = request.headers['Authorization']&.split(' ')&.last
    # p "TOKEN"
    # p token
    return unauthorized unless token.present?

    # Verify the token by its hash
    jwt_token = Token.verify_token(token)
    # p "JWT"
    # p jwt_token
    return unauthorized unless jwt_token

    # Decode the token
    # decoded_token = Token.decode_token(token)
    # p "decoded"
    # p decoded_token
    # return unauthorized unless decoded_token

    @current_user = User.find_by(id: jwt_token[:user_id])
    return unauthorized unless @current_user

    true
  end

  def is_admin?
    unless current_user && current_user.is_admin?
      flash[:warning] = "Not authorized"
      redirect_to root_path
    end
  end

	def layout_by_resource
    if controller_name == 'errors'
      'errors'
    elsif controller_name == 'sessions'
      'login'
    else
      'application'
    end
  end

  def unauthorized
    render json: { 'code': 401, 'status': 'unauthorized' }, status: :unauthorized
  end
  
end
