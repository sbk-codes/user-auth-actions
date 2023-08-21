class User < ApplicationRecord
  validates :user_id, presence: true
  validates :password, presence: true, length: { in: 8..20 }
end
