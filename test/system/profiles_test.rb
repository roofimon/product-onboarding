require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    # Login as a regular user
    visit login_path
    fill_in "email", with: "seller1@example.com"
    fill_in "password", with: "password123"
    click_button "Sign In"
    
    # Verify login was successful
    assert_text "Hello, John!"
  end

  test "user can update profile information" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Edit Profile"

    fill_in "user[name]", with: "UpdatedName"
    fill_in "user[surname]", with: "UpdatedSurname"
    fill_in "user[email]", with: "updated@example.com"

    click_button "Update Profile"

    # Should show success message
    assert_text "Profile updated successfully!"
    
    # Should show updated information
    assert_text "UpdatedName UpdatedSurname"
    assert_text "updated@example.com"
  end

  test "user cannot update profile with invalid email" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Edit Profile"
    
    # Wait for edit form to load
    assert_text "Edit Profile"

    # Use JavaScript to bypass HTML5 validation
    page.execute_script("document.querySelector('input[name=\"user[email]\"]').setAttribute('type', 'text')")
    fill_in "user[email]", with: "invalid-email"

    click_button "Update Profile"

    # Should show validation error
    assert_text "Email is invalid"
  end

  test "user can change password with correct current password" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Change Password"

    fill_in "user[current_password]", with: "password123"
    fill_in "user[password]", with: "newpassword123"
    fill_in "user[password_confirmation]", with: "newpassword123"

    click_button "Update Password"

    # Should show success message
    assert_text "Password updated successfully!"
    
    # Verify can login with new password
    accept_confirm do
      click_link "Logout"
    end

    visit login_path
    fill_in "email", with: "seller1@example.com"
    fill_in "password", with: "newpassword123"
    click_button "Sign In"

    assert_text "Hello, John!" # Name is still John, not UpdatedName
  end

  test "user cannot change password with incorrect current password" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Change Password"

    fill_in "user[current_password]", with: "wrongpassword"
    fill_in "user[password]", with: "newpassword123"
    fill_in "user[password_confirmation]", with: "newpassword123"

    click_button "Update Password"

    # Should show error message
    assert_text "Current password is incorrect"
  end

  test "user cannot change password when passwords don't match" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Change Password"

    fill_in "user[current_password]", with: "password123"
    fill_in "user[password]", with: "newpassword123"
    fill_in "user[password_confirmation]", with: "differentpassword"

    click_button "Update Password"

    # Should show validation error
    assert_text "Password confirmation doesn't match Password"
  end

  test "user cannot change password with short password" do
    visit profile_path
    
    # Wait for page to load
    assert_text "Your Profile"

    click_link "Change Password"

    fill_in "user[current_password]", with: "password123"
    fill_in "user[password]", with: "short"
    fill_in "user[password_confirmation]", with: "short"

    click_button "Update Password"

    # Should show validation error
    assert_text "Password is too short"
  end
end
