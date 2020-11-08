class User < ApplicationRecord
  # Include devise modules.
  # Defaults are: :database_authenticatable, :registerable,
  #   :recoverable, :rememberable, :validatable
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :user_visits
  has_many :bookmarks

end
