class Theme < ApplicationRecord
  has_many :theme_pages, dependent: :destroy
end
