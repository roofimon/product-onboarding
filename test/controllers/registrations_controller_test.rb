require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should post create with valid params" do
    post signup_url, params: { user: { name: "New", surname: "User", email: "newuser@example.com", password: "password123", password_confirmation: "password123" } }
    assert_response :redirect
  end
end
