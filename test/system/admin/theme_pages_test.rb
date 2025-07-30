require "application_system_test_case"

class Admin::ThemePagesTest < ApplicationSystemTestCase
  setup do
    @admin_theme_page = admin_theme_pages(:one)
  end

  test "visiting the index" do
    visit admin_theme_pages_url
    assert_selector "h1", text: "Theme pages"
  end

  test "should create theme page" do
    visit admin_theme_pages_url
    click_on "New theme page"

    fill_in "Component order", with: @admin_theme_page.component_order
    fill_in "Page type", with: @admin_theme_page.page_type
    fill_in "Theme", with: @admin_theme_page.theme_id
    click_on "Create Theme page"

    assert_text "Theme page was successfully created"
    click_on "Back"
  end

  test "should update Theme page" do
    visit admin_theme_page_url(@admin_theme_page)
    click_on "Edit this theme page", match: :first

    fill_in "Component order", with: @admin_theme_page.component_order
    fill_in "Page type", with: @admin_theme_page.page_type
    fill_in "Theme", with: @admin_theme_page.theme_id
    click_on "Update Theme page"

    assert_text "Theme page was successfully updated"
    click_on "Back"
  end

  test "should destroy Theme page" do
    visit admin_theme_page_url(@admin_theme_page)
    click_on "Destroy this theme page", match: :first

    assert_text "Theme page was successfully destroyed"
  end
end
