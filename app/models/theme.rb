class Theme < ApplicationRecord
  has_many :theme_pages, dependent: :destroy
  has_many :websites
end
