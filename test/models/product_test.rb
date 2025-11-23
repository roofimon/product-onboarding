require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Jane",
      surname: "Doe",
      email: "jane.doe@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @product = Product.new(
      name: "Vintage Camera",
      description: "A beautiful vintage camera in great condition.",
      open_price: 100.0,
      price_per_bid: 10.0,
      user: @user
    )
  end

  test "should be valid" do
    assert @product.valid?
  end

  test "name should be present" do
    @product.name = " "
    assert_not @product.valid?
  end

  test "name should be at least 2 characters" do
    @product.name = "a"
    assert_not @product.valid?
  end

  test "name should be at most 255 characters" do
    @product.name = "a" * 256
    assert_not @product.valid?
  end

  test "description should be present" do
    @product.description = " "
    assert_not @product.valid?
  end

  test "description should be at least 10 characters" do
    @product.description = "Short"
    assert_not @product.valid?
  end

  test "open_price should be present" do
    @product.open_price = nil
    assert_not @product.valid?
  end

  test "open_price should be greater than 0" do
    @product.open_price = 0
    assert_not @product.valid?
    @product.open_price = -10
    assert_not @product.valid?
  end

  test "price_per_bid should be present" do
    @product.price_per_bid = nil
    assert_not @product.valid?
  end

  test "price_per_bid should be greater than 0" do
    @product.price_per_bid = 0
    assert_not @product.valid?
    @product.price_per_bid = -5
    assert_not @product.valid?
  end

  test "should belong to a user" do
    @product.user = nil
    assert_not @product.valid?
  end
end
