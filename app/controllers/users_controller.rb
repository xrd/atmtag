class UsersController < ApplicationController
  def create_from_token
    unless current_user
      token = params[:token]
      u = User.create email: "#{token}@atmtag.com", password: SecureRandom.hex(10)
      cookies[:user_token] = u.email
      session[:user_id] = u.id
    end
    render json: { token: params[:token] }
  end
  
end
