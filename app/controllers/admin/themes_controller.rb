class Admin::ThemesController < ApplicationController
  layout 'admin'
  before_action :set_theme, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :admin?

  # GET /admin/themes
  def index
    @themes = Theme.all
  end

  # GET /admin/themes/1
  def show
    @themePages = ThemePage.where(theme_id: params[:id])
  end

  # Add this action to your ThemePagesController (likely in app/controllers/admin/theme_pages_controller.rb)

  def reorder
    @theme = Theme.find(params[:theme_id])
    page_ids = params[:page_ids]

    if page_ids.present? && page_ids.is_a?(Array)
      ActiveRecord::Base.transaction do
        page_ids.each_with_index do |page_id, index|
          theme_page = @theme.theme_pages.find(page_id)
          theme_page.update!(component_order: index + 1)
        end
      end

      render json: { success: true }
    else
      render json: { success: false, error: 'Invalid page IDs' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: 'Page not found' }, status: :not_found
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # GET /admin/themes/new
  def new
    @theme = Theme.new
  end

  # GET /admin/themes/1/edit
  def edit
  end

  # POST /admin/themes
  def create
    @theme = Theme.new(theme_params)

    if @theme.save
      redirect_to [:admin, @theme], notice: "Theme was successfully created."
    else
      render :new, status: :unprocessable_entity
    end

    homePage = ThemePage.create(theme_id: @theme.id, page_type: 'Home', component_order: 1, package: 'Bespoke')
    aboutPage = ThemePage.create(theme_id: @theme.id, page_type: 'About', component_order: 2, package: 'Bespoke')
    servicePage = ThemePage.create(theme_id: @theme.id, page_type: 'Services', component_order: 3, package: 'Bespoke')
    contactPage = ThemePage.create(theme_id: @theme.id, page_type: 'Contact', component_order: 4, package: 'Bespoke')
  end

  # PATCH/PUT /admin/themes/1
  def update
    if @theme.update(theme_params)
      redirect_to [:admin, @theme], notice: "Theme was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/themes/1
  def destroy
    @theme.destroy!
    redirect_to admin_themes_path, notice: "Theme was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = Theme.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def theme_params
      params.expect(theme: [ :name, :placeholder_image, :description ])
    end
end
