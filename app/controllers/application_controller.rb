class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  before_action :authenticate_user!
  before_action :verify_jti

  private
  def verify_jti
    return unless current_user

    token = request.headers['Authorization']&.split&.last
    return head :unauthorized unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
      token_jti = decoded_token.first['jti']
      if current_user.jti != token_jti
        sign_out(current_user)
        render json: { error: 'Token has been revoked' }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
