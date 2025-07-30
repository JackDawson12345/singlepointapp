require "application_system_test_case"

class Admin::ComponentsTest < ApplicationSystemTestCase
  setup do
    @admin_component = admin_components(:one)
  end

  test "visiting the index" do
    visit admin_components_url
    assert_selector "h1", text: "Components"
  end

  test "should create component" do
    visit admin_components_url
    click_on "New component"

    fill_in "Css content", with: @admin_component.css_content
    fill_in "Editable fields", with: @admin_component.editable_fields
    fill_in "Html content", with: @admin_component.html_content
    fill_in "Js content", with: @admin_component.js_content
    fill_in "Name", with: @admin_component.name
    click_on "Create Component"

    assert_text "Component was successfully created"
    click_on "Back"
  end

  test "should update Component" do
    visit admin_component_url(@admin_component)
    click_on "Edit this component", match: :first

    fill_in "Css content", with: @admin_component.css_content
    fill_in "Editable fields", with: @admin_component.editable_fields
    fill_in "Html content", with: @admin_component.html_content
    fill_in "Js content", with: @admin_component.js_content
    fill_in "Name", with: @admin_component.name
    click_on "Update Component"

    assert_text "Component was successfully updated"
    click_on "Back"
  end

  test "should destroy Component" do
    visit admin_component_url(@admin_component)
    click_on "Destroy this component", match: :first

    assert_text "Component was successfully destroyed"
  end
end
