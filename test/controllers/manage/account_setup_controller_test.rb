require "test_helper"

class Manage::AccountSetupControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_account_setup_index_url
    assert_response :success
  end
end
