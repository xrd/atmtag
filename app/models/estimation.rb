class Estimation < ActiveRecord::Base
  belongs_to :user
  attr_accessible :fee, :name, :lat, :lng, :uid
end
