require "test_helper"

class Admin::ComponentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_component = admin_components(:one)
  end

  test "should get index" do
    get admin_components_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_component_url
    assert_response :success
  end

  test "should create admin_component" do
    assert_difference("Admin::Component.count") do
      post admin_components_url, params: { admin_component: { css_content: @admin_component.css_content, editable_fields: @admin_component.editable_fields, html_content: @admin_component.html_content, js_content: @admin_component.js_content, name: @admin_component.name } }
    end

    assert_redirected_to admin_component_url(Admin::Component.last)
  end

  test "should show admin_component" do
    get admin_component_url(@admin_component)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_component_url(@admin_component)
    assert_response :success
  end

  test "should update admin_component" do
    patch admin_component_url(@admin_component), params: { admin_component: { css_content: @admin_component.css_content, editable_fields: @admin_component.editable_fields, html_content: @admin_component.html_content, js_content: @admin_component.js_content, name: @admin_component.name } }
    assert_redirected_to admin_component_url(@admin_component)
  end

  test "should destroy admin_component" do
    assert_difference("Admin::Component.count", -1) do
      delete admin_component_url(@admin_component)
    end

    assert_redirected_to admin_components_url
  end
end
