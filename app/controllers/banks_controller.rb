class BanksController < ApplicationController
  def index
    render json: Bank.all
  end

  def add_estimation
    estimation = params[:estimation]
    out = current_user.estimations.create estimation
    render json: { status: ( out.persisted? ? "ok" : "failure" ) }
  end
  
end
