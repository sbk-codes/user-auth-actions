class Api::V1::UsersController < ApplicationController
  before_action :check_required_params, only: %i[signup show update]
  before_action :set_user, only: %i[show update]

  def signup
    user = User.new(user_params)

    if user.save
      render_user_response('Account successfully created', user)
    else
      render_error_response('Account creation failed', user.errors.full_messages.join(', '))
    end
  end

  def show
    requested_user = User.find_by(user_id: params[:user_id])

    if requested_user
      if authorized_user?
        render_user_response('User details by user_id', requested_user)
      else
        render_unauthorized_response('Authentication Failed')
      end
    else
      render_not_found_response('No User found')
    end
  end

  def update
    if authorized_user? && @auth_user == @user
      @user.update(user_update_params)
      render_user_response('User successfully updated', @user) && return
    end

    if @auth_user != @user && !@auth_user.nil?
      render_forbidden_response('No Permission for Update')
    else
      render_unauthorized_response('Authentication Failed')
    end
  end

  def close
    if authorized_user?
      @auth_user.destroy
      render_success_response('Account and user successfully removed')
    else
      render_unauthorized_response('Authentication Failed')
    end
  end

  private

  def check_required_params
    case action_name.to_sym
    when :signup
      if params[:user_id].blank? || params[:password].blank?
        render_error_response('Account creation failed', 'required user_id and password')
        # render_bad_request_response('required user_id and password')
      end
    when :show, :update
      render_bad_request_response('user_id is required') if params[:user_id].blank?
    end
  end

  def set_user
    @user = User.find_by(user_id: params[:user_id])
    render_unauthorized_response('Authentication Failed') unless @user
  end

  def user_params
    params.permit(:user_id, :password)
  end

  def user_update_params
    params.permit(:nickname, :comment)
  end

  def render_user_response(message, user)
    render json: {
      message: message,
      user: {
        user_id: user.user_id,
        nickname: user.nickname || user.user_id,
        comment: user.comment
      }
    }, status: :ok
  end

  def render_error_response(message, cause)
    render json: {
      message: message,
      cause: cause
    }, status: :bad_request
  end

  def render_not_found_response(message)
    render json: { message: message }, status: :not_found
  end

  def render_forbidden_response(message)
    render json: { message: message }, status: :forbidden
  end

  def render_success_response(message)
    render json: { message: message }, status: :ok
  end

  def render_unauthorized_response(message)
    render json: { message: message }, status: :unauthorized
  end

  def render_bad_request_response(cause)
    render json: {
      message: 'Bad Request',
      cause: cause
    }, status: :bad_request
  end

  def authorized_user?
    user_id, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
    @auth_user = User.find_by(user_id: user_id)
    return false unless @auth_user

    @auth_user.password == password
  end
end
