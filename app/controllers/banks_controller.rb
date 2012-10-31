class BanksController < ApplicationController
  def index
    render json: Bank.all
  end
end
