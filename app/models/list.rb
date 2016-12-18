class List < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :albums 
  validates(:name, presence: true, length: { maximum: 150 })
   
   
  accepts_nested_attributes_for :albums 
end
