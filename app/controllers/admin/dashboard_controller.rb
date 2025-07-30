class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :admin?
  def index
    @components = Component.all
    @themes = Theme.all
    @websites = Website.all
  end
end
