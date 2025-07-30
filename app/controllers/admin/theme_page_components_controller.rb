class Admin::ThemePageComponentsController < ApplicationController
  layout 'admin'
  before_action :set_theme_page_component, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :admin?

  # GET /admin/theme_page_components
  def index
    @theme_page_components = ThemePageComponent.all
  end

  # GET /admin/theme_page_components/1
  def show
  end

  # GET /admin/theme_page_components/new
  def new
    @theme = Theme.find(params[:theme_id])
    @themePage = ThemePage.find(params[:page_id])
    @components = Component.all
    @themePageComponents = ThemePageComponent.where(theme_page_id: @themePage.id)
    @theme_page_component = ThemePageComponent.new
    # Then you can also create a hash for faster lookups:
    @existing_component_ids = ThemePageComponent.where(theme_page_id: params[:page_id])
                                                .pluck(:component_id)
                                                .to_set
  end

  def new_ajax
    component_id = params[:component_id]
    theme_id = params[:theme_id]
    page_id = params[:page_id]
    currentComponents = ThemePageComponent.where(theme_page_id: page_id).order(position: :desc)

    position = currentComponents.any? ? currentComponents.first.position + 1 : 1
    ThemePageComponent.create(component_id: component_id, theme_page_id: page_id, position: position)

    # Reload the components for the response
    @themePageComponents = ThemePageComponent.where(theme_page_id: page_id).order(position: :asc)

    respond_to do |format|
      format.js # This will render new_ajax.js.erb
    end
  end

  def delete_ajax
    theme_page_component_id = params[:id]
    page_id = params[:page_id]

    # Find the component to delete
    theme_page_component = ThemePageComponent.find(theme_page_component_id)
    deleted_position = theme_page_component.position

    # Delete the component
    theme_page_component.destroy!

    # Update positions of all components that came after the deleted one
    ThemePageComponent.where(theme_page_id: page_id)
                      .where('position > ?', deleted_position)
                      .update_all('position = position - 1')

    # Reload the components for the response
    @themePageComponents = ThemePageComponent.where(theme_page_id: page_id).order(position: :asc)

    respond_to do |format|
      format.js # This will render delete_ajax.js.erb
    end
  end

  def update_positions
    component_ids = params[:component_ids]
    page_id = params[:page_id]

    if component_ids.present?
      # Update positions based on the new order
      component_ids.each_with_index do |component_id, index|
        ThemePageComponent.where(id: component_id, theme_page_id: page_id)
                          .update_all(position: index + 1)
      end

      render json: { success: true }
    else
      render json: { success: false, error: 'No component IDs provided' }
    end
  rescue => e
    render json: { success: false, error: e.message }
  end

  # GET /admin/theme_page_components/1/edit
  def edit
  end

  # POST /admin/theme_page_components
  def create
    @theme_page_component = ThemePageComponent.new(theme_page_component_params)

    if @theme_page_component.save
      redirect_to [:admin, @theme_page_component], notice: "Theme page component was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/theme_page_components/1
  def update
    if @theme_page_component.update(theme_page_component_params)
      redirect_to [:admin, @theme_page_component], notice: "Theme page component was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/theme_page_components/1
  def destroy
    @theme_page_component.destroy!
    redirect_to theme_page_components_path, notice: "Theme page component was successfully destroyed.", status: :see_other
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_theme_page_component
    @theme_page_component = ThemePageComponent.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def theme_page_component_params
    params.expect(theme_page_component: [ :theme_page_id, :component_id, :position ])
  end
end