require "test_helper"

class Admin::ThemePagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_theme_page = admin_theme_pages(:one)
  end

  test "should get index" do
    get admin_theme_pages_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_theme_page_url
    assert_response :success
  end

  test "should create admin_theme_page" do
    assert_difference("Admin::ThemePage.count") do
      post admin_theme_pages_url, params: { admin_theme_page: { component_order: @admin_theme_page.component_order, page_type: @admin_theme_page.page_type, theme_id: @admin_theme_page.theme_id } }
    end

    assert_redirected_to admin_theme_page_url(Admin::ThemePage.last)
  end

  test "should show admin_theme_page" do
    get admin_theme_page_url(@admin_theme_page)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_theme_page_url(@admin_theme_page)
    assert_response :success
  end

  test "should update admin_theme_page" do
    patch admin_theme_page_url(@admin_theme_page), params: { admin_theme_page: { component_order: @admin_theme_page.component_order, page_type: @admin_theme_page.page_type, theme_id: @admin_theme_page.theme_id } }
    assert_redirected_to admin_theme_page_url(@admin_theme_page)
  end

  test "should destroy admin_theme_page" do
    assert_difference("Admin::ThemePage.count", -1) do
      delete admin_theme_page_url(@admin_theme_page)
    end

    assert_redirected_to admin_theme_pages_url
  end
end
