class Admin::WebsitesController < ApplicationController
  layout 'admin'
  before_action :set_admin_website, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :admin?

  # GET /admin/websites
  def index
    @admin_websites = Admin::Website.all
  end

  # GET /admin/websites/1
  def show
  end

  # GET /admin/websites/new
  def new
    @admin_website = Admin::Website.new
  end

  # GET /admin/websites/1/edit
  def edit
  end

  # POST /admin/websites
  def create
    @admin_website = Admin::Website.new(admin_website_params)

    if @admin_website.save
      redirect_to @admin_website, notice: "Website was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/websites/1
  def update
    if @admin_website.update(admin_website_params)
      redirect_to @admin_website, notice: "Website was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/websites/1
  def destroy
    @admin_website.destroy!
    redirect_to admin_websites_path, notice: "Website was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_website
      @admin_website = Admin::Website.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_website_params
      params.expect(admin_website: [ :user_id, :theme_id, :name, :subdomain, :content_data ])
    end


end
