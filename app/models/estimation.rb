class Estimation < ActiveRecord::Base
  belongs_to :user
  attr_accessible :fee, :name, :lat, :lng, :uid
  validates_presence_of :fee, :name, :lat, :lng, :uid, :user_id
  validates_uniqueness_of :user_id, :scope => [ :fee, :name, :lat, :lng, :uid ]
end
