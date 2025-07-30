class Manage::AccountSetupController < ApplicationController
  layout 'manage'
  before_action :authenticate_user!
  before_action :customer?

  def index
  end
end
