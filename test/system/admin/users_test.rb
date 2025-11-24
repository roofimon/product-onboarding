require "application_system_test_case"

class Admin::UsersTest < ApplicationSystemTestCase
  include ActionView::RecordIdentifier

  setup do
    # Login as admin
    visit login_path
    fill_in "email", with: "admin@example.com"
    fill_in "password", with: "password123"
    click_button "Sign In"
    
    # Wait for redirect to admin dashboard
    assert_current_path admin_dashboard_path
  end

  test "admin can approve a waiting user" do
    # Create a waiting user
    waiting_user = User.create!(
      name: "Waiting",
      surname: "User",
      email: "waiting@example.com",
      password: "password123",
      password_confirmation: "password123",
      status: :waiting_for_approve
    )

    visit admin_users_path
    
    # Wait for the page to load
    assert_text "User Management"

    # Click on the approve button for the waiting user
    accept_confirm do
      find("##{dom_id(waiting_user, :approve_button)}").click
    end

    # Verify the user status badge changed to Active
    within("##{dom_id(waiting_user, :status_cell)}") do
      assert_selector ".badge", text: /active/i
    end
    
    # Verify the user status changed in database
    waiting_user.reload
    assert waiting_user.active?
  end

  test "admin can deactivate an active user" do
    # Use an existing active user from fixtures
    active_user = users(:seller_one)

    visit admin_users_path
    
    # Wait for the page to load
    assert_text "User Management"

    # Click on the deactivate button for the active user
    accept_confirm do
      find("##{dom_id(active_user, :deactivate_button)}").click
    end

    # Verify the user status badge changed to Inactive
    within("##{dom_id(active_user, :status_cell)}") do
      assert_selector ".badge", text: /inactive/i
    end
    
    # Verify the user status changed in database
    active_user.reload
    assert active_user.inactive?
  end

  test "admin can activate an inactive user" do
    # Create an inactive user
    inactive_user = User.create!(
      name: "Inactive",
      surname: "User",
      email: "inactive@example.com",
      password: "password123",
      password_confirmation: "password123",
      status: :inactive
    )

    visit admin_users_path
    
    # Wait for the page to load
    assert_text "User Management"

    # Click on the activate button for the inactive user
    accept_confirm do
      find("##{dom_id(inactive_user, :activate_button)}").click
    end

    # Verify the user status badge changed to Active
    within("##{dom_id(inactive_user, :status_cell)}") do
      assert_selector ".badge", text: /active/i
    end
    
    # Verify the user status changed in database
    inactive_user.reload
    assert inactive_user.active?
  end

  test "admin can filter users by status" do
    visit admin_users_path
    
    # Wait for the page to load
    assert_text "User Management"

    # Click on waiting filter
    find("#admin-users-filter-waiting").click
    assert_current_path admin_users_path(status: "waiting_for_approve")

    # Click on active filter
    find("#admin-users-filter-active").click
    assert_current_path admin_users_path(status: "active")

    # Click on inactive filter
    find("#admin-users-filter-inactive").click
    assert_current_path admin_users_path(status: "inactive")

    # Click on all filter
    find("#admin-users-filter-all").click
    assert_current_path admin_users_path
  end
end

