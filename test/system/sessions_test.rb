require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "successful login with valid credentials" do
    visit login_path

    fill_in "email", with: "seller1@example.com"
    fill_in "password", with: "password123"
    click_button "Sign In"

    # After successful login, user should be redirected to root path
    assert_current_path root_path
    # And should see their name in the navigation
    assert_text "Hello, John!"
  end

  test "failed login with invalid credentials" do
    visit login_path

    fill_in "email", with: "seller1@example.com"
    fill_in "password", with: "wrongpassword"
    click_button "Sign In"

    assert_text "Invalid email or password"
    assert_current_path login_path
  end

  test "failed login with non-existent email" do
    visit login_path

    fill_in "email", with: "nonexistent@example.com"
    fill_in "password", with: "password123"
    click_button "Sign In"

    assert_text "Invalid email or password"
    assert_current_path login_path
  end

  # test "successful logout" do
  #   # First, log in
  #   visit login_path
  #   fill_in "email", with: "seller1@example.com"
  #   fill_in "password", with: "password123"
  #   click_button "Sign In"

  #   assert_text "Hello, John!"

  #   # Then, log out (accept the confirmation dialog)
  #   accept_confirm do
  #     click_link "Logout"
  #   end

  #   # After logout, user should be redirected to root path
  #   assert_current_path root_path
  #   # And should see the Login button instead of user greeting
  #   assert_text "Login"
  #   assert_no_text "Hello, John!"
  # end
end
