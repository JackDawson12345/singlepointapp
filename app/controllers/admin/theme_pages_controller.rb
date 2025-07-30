# app/controllers/admin/theme_pages_controller.rb
class Admin::ThemePagesController < ApplicationController
  layout 'admin'
  before_action :set_theme_page, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :admin?

  # GET /admin/theme_pages
  def index
    @theme_pages = ThemePage.all
  end

  # GET /admin/theme_pages/1
  def show
    @theme_page = ThemePage.find(params[:id])
    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @theme_page.id })
                           .order('theme_page_components.position')

    # Ensure we have access to the theme for template processing
    @theme = @theme_page.theme

    # Use a different layout for preview
    render layout: false
  end

  # GET /admin/theme_pages/new
  def new
    @theme_page = ThemePage.new
  end

  # GET /admin/theme_pages/1/edit
  def edit
  end

  # POST /admin/theme_pages
  def create
    @theme_page = ThemePage.new(theme_page_params)

    if @theme_page.save
      redirect_to [:admin, @theme_page], notice: "Theme page was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/theme_pages/1
  def update
    if @theme_page.update(theme_page_params)
      redirect_to [:admin, @theme_page], notice: "Theme page was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/theme_pages/1
  def destroy
    @theme_page.destroy!
    redirect_to admin_theme_path(params[:theme_id]), notice: "Theme page was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_theme_page
    @theme_page = ThemePage.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def theme_page_params
    params.expect(theme_page: [ :theme_id, :page_type, :component_order ])
  end
end