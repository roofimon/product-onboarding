require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  test "successful registration with valid data" do
    visit signup_path

    fill_in "user[name]", with: "Alice"
    fill_in "user[surname]", with: "Cooper"
    fill_in "user[email]", with: "alice.cooper@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"

    click_button "Create Account"

    # Should be redirected to registration completed page
    assert_current_path registration_completed_path
    assert_text "Welcome, Alice Cooper!"
  end

  test "failed registration with missing required fields" do
    visit signup_path

    # Fill in some fields but leave name empty to test server-side validation
    # (HTML5 validation would prevent submission with all empty fields)
    fill_in "user[surname]", with: "Smith"
    fill_in "user[email]", with: "test@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"

    # Use JavaScript to bypass HTML5 validation
    page.execute_script("document.querySelector('input[name=\"user[name]\"]').removeAttribute('required')")

    click_button "Create Account"

    # Should show validation error for name
    assert_text "Name can't be blank"
  end

  test "failed registration with password mismatch" do
    visit signup_path

    fill_in "user[name]", with: "Bob"
    fill_in "user[surname]", with: "Smith"
    fill_in "user[email]", with: "bob.smith@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "different_password"

    click_button "Create Account"

    # Should show password confirmation error
    assert_text "Password confirmation doesn't match Password"
  end

  test "failed registration with duplicate email" do
    visit signup_path

    # Use an email that already exists in fixtures
    fill_in "user[name]", with: "Test"
    fill_in "user[surname]", with: "User"
    fill_in "user[email]", with: "seller1@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"

    click_button "Create Account"

    # Should show email uniqueness error
    assert_text "Email has already been taken"
  end

  test "failed registration with invalid email format" do
    visit signup_path

    fill_in "user[name]", with: "Test"
    fill_in "user[surname]", with: "User"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"

    # Use JavaScript to bypass HTML5 email validation
    page.execute_script("document.querySelector('input[name=\"user[email]\"]').setAttribute('type', 'text')")
    fill_in "user[email]", with: "invalid-email"

    click_button "Create Account"

    # Should show email format error
    assert_text "Email is invalid"
  end

  test "failed registration with short password" do
    visit signup_path

    fill_in "user[name]", with: "Test"
    fill_in "user[surname]", with: "User"
    fill_in "user[email]", with: "test@example.com"
    fill_in "user[password]", with: "short"
    fill_in "user[password_confirmation]", with: "short"

    click_button "Create Account"

    # Should show password length error
    assert_text "Password is too short"
  end

  test "failed registration with short name" do
    visit signup_path

    fill_in "user[name]", with: "A"
    fill_in "user[surname]", with: "Smith"
    fill_in "user[email]", with: "test@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"

    click_button "Create Account"

    # Should show name length error
    assert_text "Name is too short"
  end
end
