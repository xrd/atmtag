class Estimation < ActiveRecord::Base
  belongs_to :user
  attr_accessible :fee, :name, :lat, :lng, :uid
  validates_presence_of :fee, :name, :lat, :lng, :uid
end
