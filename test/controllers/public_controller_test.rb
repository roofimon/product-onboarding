require "test_helper"

class PublicControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:vintage_watch)
  end

  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h2", /All Products/ # Match dynamic header
    assert_select ".product-card", minimum: 1 # Assuming product cards have this class
  end

  test "should get show" do
    get public_product_url(@product)
    assert_response :success
    assert_match @product.name, response.body
  end

  test "should search products" do
    get root_url, params: { search: @product.name }
    assert_response :success
    assert_match @product.name, response.body
  end

  test "should sort products price low to high" do
    get root_url, params: { sort: 'price_low_high' }
    assert_response :success
    assert_select ".product-card"
  end

  test "should sort products price high to low" do
    get root_url, params: { sort: 'price_high_low' }
    assert_response :success
    assert_select ".product-card"
  end

  test "should paginate products" do
    get root_url
    assert_response :success
    assert_select ".pagy-nav" # Assuming pagy nav is present
  end
end
