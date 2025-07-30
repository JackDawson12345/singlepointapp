require "application_system_test_case"

class Admin::ThemePageComponentsTest < ApplicationSystemTestCase
  setup do
    @admin_theme_page_component = admin_theme_page_components(:one)
  end

  test "visiting the index" do
    visit admin_theme_page_components_url
    assert_selector "h1", text: "Theme page components"
  end

  test "should create theme page component" do
    visit admin_theme_page_components_url
    click_on "New theme page component"

    fill_in "Component", with: @admin_theme_page_component.component_id
    fill_in "Position", with: @admin_theme_page_component.position
    fill_in "Theme page", with: @admin_theme_page_component.theme_page_id
    click_on "Create Theme page component"

    assert_text "Theme page component was successfully created"
    click_on "Back"
  end

  test "should update Theme page component" do
    visit admin_theme_page_component_url(@admin_theme_page_component)
    click_on "Edit this theme page component", match: :first

    fill_in "Component", with: @admin_theme_page_component.component_id
    fill_in "Position", with: @admin_theme_page_component.position
    fill_in "Theme page", with: @admin_theme_page_component.theme_page_id
    click_on "Update Theme page component"

    assert_text "Theme page component was successfully updated"
    click_on "Back"
  end

  test "should destroy Theme page component" do
    visit admin_theme_page_component_url(@admin_theme_page_component)
    click_on "Destroy this theme page component", match: :first

    assert_text "Theme page component was successfully destroyed"
  end
end
