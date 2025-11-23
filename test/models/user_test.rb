require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "John",
      surname: "Doe",
      email: "john.doe@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "name should be at least 2 characters" do
    @user.name = "a"
    assert_not @user.valid?
  end

  test "name should be at most 50 characters" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "surname should be present" do
    @user.surname = " "
    assert_not @user.valid?
  end

  test "surname should be at least 2 characters" do
    @user.surname = "a"
    assert_not @user.valid?
  end

  test "surname should be at most 50 characters" do
    @user.surname = "a" * 51
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "status should be present" do
    @user.status = nil
    assert_not @user.valid?
  end

  test "should have correct status enums" do
    assert_equal "waiting_for_approve", User.statuses.key(0)
    assert_equal "active", User.statuses.key(1)
    assert_equal "inactive", User.statuses.key(2)
  end

  test "default status should be waiting_for_approve" do
    user = User.new
    assert user.waiting_for_approve?
  end

  test "should destroy associated products" do
    @user.save
    @user.products.create!(
      name: "Test Product",
      description: "Test Description",
      open_price: 10.0,
      price_per_bid: 1.0
    )
    assert_difference "Product.count", -1 do
      @user.destroy
    end
  end
end
