class Bank < ActiveRecord::Base 
  attr_accessible :name, :state, :country
  has_many :fees
end
