class Admin::ComponentsController < ApplicationController
  layout 'admin'
  before_action :set_component, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :admin?

  # GET /admin/components
  def index
    @components = Component.all
  end

  # GET /admin/components/1
  def show
  end

  # GET /admin/components/new
  def new
    @component = Component.new
  end

  # GET /admin/components/1/edit
  def edit
  end

  # POST /admin/components
  def create
    @component = Component.new(component_params)

    if @component.save
      redirect_to [:admin, @component], notice: "Component was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/components/1
  def update
    if @component.update(component_params)
      redirect_to [:admin, @component], notice: "Component was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/components/1
  def destroy
    @component.destroy!
    redirect_to admin_components_path, notice: "Component was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_component
      @component = Component.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def component_params
      params.expect(component: [ :name, :html_content, :css_content, :js_content, :editable_fields, :component_type, :template_patterns, :global ])
    end
end
