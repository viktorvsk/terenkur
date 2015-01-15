class Api::V1::ApiController < ActionController::Base
  EC = {
    '0' => ['Unknown error', 400],
    '1' => ['Missing Authenticateion Headers. Please provide your email and token using X-User-Email and X-User-Token', 400],
    '2' => ['Unauthorized', 401],
    '3' => ['Missing API key', 400],
    '4' => ['Invalid API key', 401],
    '5' => ['Not authorized', 401]
  }

  acts_as_token_authentication_handler_for User, fallback_to_devise: false
  before_filter :default_format_json, :authenticate!

  def default_format_json
    request.format = :json unless params[:format]
  end

  def error!(code=0)
    render json: { success: 0, error_code: code, error_message: EC[code.to_s][0] }, status: EC[code.to_s][1]
  end

  def success!(message='No message')
    render json: { success: 1, message: message }, status: 200
  end

  private
  def authenticate!
    error!(1) and return if !( params[:user_email].present? and params[:user_token].present? ) and !( request.headers['X-User-Token'].present? and request.headers['X-User-Email'].present? )
    error!(2) and return unless current_user
  end

end