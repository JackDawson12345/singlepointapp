class Manage::WebsiteBuilderController < ApplicationController
  def builder
    @website = current_user.website
    @websitePages = @website.theme.theme_pages
    @homePage = @websitePages.order(:component_order).first

    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @homePage.id })
                           .order('theme_page_components.position')
    render :layout => false
  end
end
