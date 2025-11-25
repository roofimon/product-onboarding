require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:seller_one)
  end

  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should post create with valid credentials" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_response :redirect
  end

  test "should delete destroy" do
    post login_url, params: { email: @user.email, password: "password123" }
    delete logout_url
    assert_response :redirect
  end
end
