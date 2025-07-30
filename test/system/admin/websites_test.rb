require "application_system_test_case"

class Admin::WebsitesTest < ApplicationSystemTestCase
  setup do
    @admin_website = admin_websites(:one)
  end

  test "visiting the index" do
    visit admin_websites_url
    assert_selector "h1", text: "Websites"
  end

  test "should create website" do
    visit admin_websites_url
    click_on "New website"

    fill_in "Content data", with: @admin_website.content_data
    fill_in "Name", with: @admin_website.name
    fill_in "Subdomain", with: @admin_website.subdomain
    fill_in "Theme", with: @admin_website.theme_id
    fill_in "User", with: @admin_website.user_id
    click_on "Create Website"

    assert_text "Website was successfully created"
    click_on "Back"
  end

  test "should update Website" do
    visit admin_website_url(@admin_website)
    click_on "Edit this website", match: :first

    fill_in "Content data", with: @admin_website.content_data
    fill_in "Name", with: @admin_website.name
    fill_in "Subdomain", with: @admin_website.subdomain
    fill_in "Theme", with: @admin_website.theme_id
    fill_in "User", with: @admin_website.user_id
    click_on "Update Website"

    assert_text "Website was successfully updated"
    click_on "Back"
  end

  test "should destroy Website" do
    visit admin_website_url(@admin_website)
    click_on "Destroy this website", match: :first

    assert_text "Website was successfully destroyed"
  end
end
