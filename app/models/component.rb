class Component < ApplicationRecord
  has_many :theme_page_components, dependent: :destroy
end
