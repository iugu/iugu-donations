class Donation < ActiveRecord::Base
  validates :email, :amount_cents, :project, presence: true

  scope :project, ->(project) { where("project = ?", project) }
end
