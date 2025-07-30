class ThemePage < ApplicationRecord

  belongs_to :theme
  has_many :theme_page_components, dependent: :destroy

  # In your ThemePage model
  PAGE_TYPES = [
    "Home",
    "About",
    "Meet the team",
    "Services",
    "Testimonials",
    "FAQs",
    "Contact"
  ].freeze

  validates :page_type, inclusion: { in: PAGE_TYPES }

  # Helper method to get page type options for select
  def self.page_type_options(theme_id = nil)
    available_types = PAGE_TYPES.dup

    if theme_id.present?
      # Convert theme_id to integer to ensure proper database query
      theme_id = theme_id.to_i
      existing_page_types = ThemePage.where(theme_id: theme_id).pluck(:page_type)
      available_types = available_types - existing_page_types
    end

    available_types.map { |type| [type, type] }
  end

  # Helper method to get next component order for a theme
  def self.next_component_order(theme_id)
    return 1 if theme_id.blank?

    # Convert theme_id to integer to ensure proper database query
    theme_id = theme_id.to_i
    max_order = ThemePage.where(theme_id: theme_id).maximum(:component_order) || 0
    max_order.to_i + 1
  end

  # Callback to set component_order before creation
  before_create :set_component_order

  private

  def set_component_order
    self.component_order ||= self.class.next_component_order(self.theme_id)
  end
end
