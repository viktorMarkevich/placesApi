class ConfirmationsController < ApplicationController
  skip_before_action :authenticate_request

  def create
    if params[:token].present? && params[:token][:confirmation_token]

      user = User.find_by(confirmation_token: params[:token][:confirmation_token])

      if user.present? && user.confirmation_token_valid? && user.mark_as_confirmed!
        auth_token = token_generator(user.id)

        if auth_token.present?
          redirect_to dashboards_path
          # render json: { status: 'User confirmed successfully', auth_token: auth_token }, status: :ok
        else
          render json: { status: 'Some thing is wrong' }, status: :not_found
        end
      else
        render json: { status: 'Invalid token' }, status: :not_found
      end
    else
      render json: { status: 'Invalid token' }, status: :not_found
    end
  end

  private

  def token_generator(user_id)
    JsonWebToken.encode(user_id: user_id)
  end

  def token_params
    params.require(:token).permit(:confirmation_token)
  end
end
