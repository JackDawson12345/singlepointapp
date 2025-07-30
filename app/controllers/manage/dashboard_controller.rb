class Manage::DashboardController < ApplicationController
  layout 'manage'
  before_action :authenticate_user!
  before_action :customer?
  before_action :account_setup?
  def index
  end
end
