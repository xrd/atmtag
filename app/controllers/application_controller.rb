class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :generate_temp_token

  def generate_temp_token
    cookies[:temp_token] = SecureRandom.hex(10) unless session[:user_id]
  end
  
  helper_method :current_user
  
  def current_user
    u = @current_user
    unless u
      if session[:user_id]
        u = User.find session[:user_id]
      end
    end
    u
  end  
  
end
