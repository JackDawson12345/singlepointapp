require "test_helper"

class Admin::ThemePageComponentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_theme_page_component = admin_theme_page_components(:one)
  end

  test "should get index" do
    get admin_theme_page_components_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_theme_page_component_url
    assert_response :success
  end

  test "should create admin_theme_page_component" do
    assert_difference("Admin::ThemePageComponent.count") do
      post admin_theme_page_components_url, params: { admin_theme_page_component: { component_id: @admin_theme_page_component.component_id, position: @admin_theme_page_component.position, theme_page_id: @admin_theme_page_component.theme_page_id } }
    end

    assert_redirected_to admin_theme_page_component_url(Admin::ThemePageComponent.last)
  end

  test "should show admin_theme_page_component" do
    get admin_theme_page_component_url(@admin_theme_page_component)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_theme_page_component_url(@admin_theme_page_component)
    assert_response :success
  end

  test "should update admin_theme_page_component" do
    patch admin_theme_page_component_url(@admin_theme_page_component), params: { admin_theme_page_component: { component_id: @admin_theme_page_component.component_id, position: @admin_theme_page_component.position, theme_page_id: @admin_theme_page_component.theme_page_id } }
    assert_redirected_to admin_theme_page_component_url(@admin_theme_page_component)
  end

  test "should destroy admin_theme_page_component" do
    assert_difference("Admin::ThemePageComponent.count", -1) do
      delete admin_theme_page_component_url(@admin_theme_page_component)
    end

    assert_redirected_to admin_theme_page_components_url
  end
end
