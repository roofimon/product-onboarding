require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    post login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_users_url
    assert_response :success
  end
end
