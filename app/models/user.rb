class User < ApplicationRecord
	has_many :lists, dependent: :destroy
	
	before_save { self.email = email.downcase }
	validates(:name, presence: true, length: { maximum: 50 })
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates(:email, presence: true, length: { maximum: 50 } , format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false })
	
	has_secure_password
	
	accepts_nested_attributes_for :lists
end
