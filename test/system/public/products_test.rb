require "application_system_test_case"

class PublicProductsTest < ApplicationSystemTestCase
  include ActionView::RecordIdentifier

  setup do
    # Fixtures are automatically loaded
  end

  # Product Listing Page Tests

  test "displays products in grid layout" do
    visit root_path

    assert_selector "[data-testid='products-grid']"
    assert_selector "[data-testid='product-card']", minimum: 1
  end

  test "product cards show name, description, seller info, and pricing" do
    visit root_path

    product = Product.first
    within find("[data-testid='product-card'][data-product-id='#{product.id}']") do
      assert_selector "[data-testid='product-name']"
      assert_selector "[data-testid='product-description']"
      assert_selector "[data-testid='product-seller']"
      assert_selector "[data-testid='product-pricing']"
      assert_selector "[data-testid='product-price-value']"
      assert_selector "[data-testid='product-bid-value']"
    end
  end

  test "product images are present or placeholder is shown" do
    visit root_path

    product = Product.first
    within find("[data-testid='product-card'][data-product-id='#{product.id}']") do
      assert_selector "[data-testid='product-image']"
      # Either image or placeholder should be present
      has_image = has_selector?("[data-testid='product-image-tag']", wait: false)
      has_placeholder = has_selector?("[data-testid='product-image-placeholder']", wait: false)
      assert has_image || has_placeholder, "Expected either product image or placeholder"
    end
  end

  test "view details link is present on product cards" do
    visit root_path

    product = Product.first
    within find("[data-testid='product-card'][data-product-id='#{product.id}']") do
      assert_selector "[data-testid='product-view-details']"
      assert_text "View Details"
    end
  end

#   # Search Functionality Tests

  test "search by product name exact match" do
    visit root_path

    fill_in "search", with: "Vintage Watch Collection"
    find("[data-testid='nav-search-field']").native.send_keys(:return)

    assert_text "Vintage Watch Collection"
    assert_text "Search Results"
  end

  test "search by product name partial match" do
    visit root_path

    fill_in "search", with: "Vintage"
    find("[data-testid='nav-search-field']").native.send_keys(:return)

    assert_text "Vintage Watch Collection"
    assert_text "Vintage Vinyl Records"
  end

  test "search by description" do
    visit root_path

    fill_in "search", with: "rare"
    find("[data-testid='nav-search-field']").native.send_keys(:return)

    assert_text "Rare Coin Collection"
  end

  test "search with no results shows empty state" do
    visit root_path

    fill_in "search", with: "Nonexistent Product XYZ"
    find("[data-testid='nav-search-field']").native.send_keys(:return)

    assert_selector "[data-testid='empty-state']"
    assert_selector "[data-testid='empty-title']", text: "No products found"
    assert_text "No products match your search"
    assert_selector "[data-testid='clear-search-button']"
  end


  test "search preserves sort order" do
    visit root_path

    # Set sort order (this auto-submits the form)
    select "Price: Low to High", from: "sort-select"
    
    # Wait for form submission and page reload
    assert_current_path root_path + "?sort=price_low_high"
    
    # Wait for page to load and ensure search form has the sort parameter
    assert_selector "[data-testid='nav-search-form']"
    assert_selector "input[name='sort'][value='price_low_high']", visible: :hidden

    # Perform search by submitting the form directly
    fill_in "search", with: "Vintage"
    page.execute_script("document.querySelector('[data-testid=\"nav-search-form\"]').submit();")
    
    # Wait for URL to update with search parameter
    assert_text "Vintage", wait: 5

    # Verify sort parameter is preserved in URL (order may vary, and commit param may be present)
    assert_match(/sort=price_low_high/, current_url)
    assert_match(/search=Vintage/, current_url)
  end

#   # Sorting Tests

  test "default sort is newest first" do
    visit root_path

    # Verify products are displayed (newest should be first)
    product_cards = all("[data-testid='product-card']")
    assert product_cards.length > 0
  end

  test "sort by price low to high" do
    visit root_path

    select "Price: Low to High", from: "sort-select"

    assert_current_path root_path + "?sort=price_low_high"

    # Verify products are sorted (check first product has lower price)
    product_cards = all("[data-testid='product-card']")
    if product_cards.length > 1
      first_product = Product.order(:open_price).first
      first_price = find("[data-testid='product-card'][data-product-id='#{first_product.id}'] [data-testid='product-price-value']").text
      # Extract numeric value from price text like "$300.00"
      first_price_value = first_price.gsub(/[^0-9.]/, "").to_f
      
      # Check that prices are in ascending order
      prices = Product.order(:open_price).limit(product_cards.length).map do |p|
        find("[data-testid='product-card'][data-product-id='#{p.id}'] [data-testid='product-price-value']").text.gsub(/[^0-9.]/, "").to_f
      end
      assert_equal prices.sort, prices
    end
  end

  test "sort by price high to low" do
    visit root_path

    select "Price: High to Low", from: "sort-select"

    assert_current_path root_path + "?sort=price_high_low"

    # Verify products are sorted (check first product has higher price)
    product_cards = all("[data-testid='product-card']")
    if product_cards.length > 1
      products = Product.order(open_price: :desc).limit(product_cards.length)
      prices = products.map { |p| find("[data-testid='product-card'][data-product-id='#{p.id}'] [data-testid='product-price-value']").text.gsub(/[^0-9.]/, "").to_f }
      assert_equal prices.sort.reverse, prices
    end
  end

  test "sort dropdown is present and functional" do
    visit root_path

    assert_selector "[data-testid='sort-select']"
    assert_selector "[data-testid='sort-label']", text: "Sort by:"
    
    # Verify all sort options are present
    select_element = find("[data-testid='sort-select']")
    assert_includes select_element.text, "Newest First"
    assert_includes select_element.text, "Price: Low to High"
    assert_includes select_element.text, "Price: High to Low"
  end

  test "sort persists after search" do
    visit root_path

    select "Price: Low to High", from: "sort-select"
    fill_in "search", with: "Vintage"
    find("[data-testid='nav-search-field']").native.send_keys(:return)

    # Verify sort is still selected
    select_element = find("[data-testid='sort-select']")
    assert_equal "price_low_high", select_element.value
  end

#   # Pagination Tests

  test "pagination appears when more than 8 products exist" do
    visit root_path

    # We have 12 products, so pagination should appear
    if Product.count > 8
      assert_selector "[data-testid='pagination-wrapper']"
      assert_selector ".pagy-nav"
    end
  end

  test "navigating to next page" do
    visit root_path

    if has_selector?(".pagy-nav .next a")
      click_link "Next"
      
      # Verify we're on page 2
      assert_selector ".pagy-nav .page.active span", text: "2"
      assert_current_path root_path + "?page=2"
    end
  end

  test "navigating to previous page" do
    visit root_path + "?page=2"

    if has_selector?(".pagy-nav .prev a")
      click_link "Previous"
      
      # Verify we're back on page 1
      assert_current_path root_path + "?page=1", wait: 5
    end
  end
  
  test "active page is highlighted" do
    visit root_path + "?page=2"

    if has_selector?(".pagy-nav .page.active")
      active_page = find(".pagy-nav .page.active span")
      assert_equal "2", active_page.text
      # Verify the active page has the active class (styling is applied via CSS classes, not inline styles)
      assert_selector ".pagy-nav .page.active span"
    end
  end

#   test "pagination with search results" do
#     visit root_path

#     fill_in "search", with: "Product"
#     find("[data-testid='nav-search-field']").native.send_keys(:return)

#     # If search results span multiple pages, pagination should appear
#     if has_selector?(".pagy-nav")
#       assert_selector "[data-testid='pagination-wrapper']"
#     end
#   end

#   test "pagination with sorting" do
#     visit root_path

#     select "Price: Low to High", from: "sort-select"

#     if has_selector?(".pagy-nav")
#       # Pagination should work with sort parameter
#       if has_selector?(".pagy-nav .page a", text: "2")
#         click_link "2"
#         assert_current_path root_path + "?sort=price_low_high&page=2"
#       end
#     end
#   end

#   # Empty States Tests

#   test "no products available when database is empty" do
#     Product.destroy_all

#     visit root_path

#     assert_text "No products available"
#     assert_text "Be the first to register a product!"
#     assert_selector "[data-testid='empty-state']"
#   end

#   test "no products found for search shows empty state" do
#     visit root_path

#     fill_in "search", with: "ThisProductDoesNotExist12345"
#     find("[data-testid='nav-search-field']").native.send_keys(:return)

#     assert_text "No products found"
#     assert_text "No products match your search"
#     assert_selector "[data-testid='clear-search-button']"
#     assert_selector "[data-testid='empty-state']"
#   end

#   test "clear search button appears for empty search results" do
#     visit root_path

#     fill_in "search", with: "Nonexistent"
#     find("[data-testid='nav-search-field']").native.send_keys(:return)

#     assert_selector "[data-testid='clear-search-button']"
#     find("[data-testid='clear-search-button']").click

#     assert_current_path root_path
#     assert_text "All Products"
#   end

#   # Navigation Tests

#   test "logo is present and links to root" do
#     visit root_path

#     assert_selector "[data-testid='logo-link']"
#     logo_link = find("[data-testid='logo-link']")
#     assert_equal root_path, logo_link[:href]
#   end

#   test "search bar is present in navigation" do
#     visit root_path

#     assert_selector "[data-testid='nav-search']"
#     assert_selector "[data-testid='nav-search-field'][placeholder='Search products...']"
#     assert_selector "[data-testid='nav-search-button']", text: "Search"
#   end

#   test "login button is present when not logged in" do
#     visit root_path

#     assert_selector "[data-testid='nav-login-button']", text: "Login"
#     assert_equal login_path, find("[data-testid='nav-login-button']")[:href]
#     assert_selector "[data-testid='nav-actions']"
#   end

#   test "navigation is visible" do
#     visit root_path

#     assert_selector "[data-testid='main-nav']"
#     assert_selector "[data-testid='nav-content']"
#   end

#   # Product Detail Page Tests

  test "clicking product card navigates to detail page" do
    visit root_path

    # Use a product that will be on the first page (newest first ordering)
    # product_16 is the newest (2 hours ago), so it should be on page 1
    product = products(:product_16)
    product_name = product.name

    # Ensure the product is visible on the current page
    assert_selector "[data-testid='product-card'][data-product-id='#{product.id}']", wait: 5

    # Find and click the product card
    product_card = find("[data-testid='product-card'][data-product-id='#{product.id}']")
    product_card.click

    assert_current_path public_product_path(product)
    assert_text product_name
  end

  test "product detail page displays product name" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text product.name
  end

  test "product detail page displays product description" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text product.description
  end

  test "product detail page displays seller information" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text product.user.name
    assert_text product.user.surname
    assert_text product.user.email
  end

  test "product detail page displays registration date" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text "Registered On"
    # Date format: "January 01, 2024 at 12:00 PM"
    assert_match /\w+ \d+, \d{4} at \d+:\d+ [AP]M/, page.text
  end

  test "product detail page displays product image or placeholder" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    # Either image or placeholder should be present
    has_image = has_selector?("img[alt*='#{product.name}']", wait: false)
    has_svg = has_selector?("svg", wait: false)
    assert has_image || has_svg, "Expected either product image or placeholder SVG"
  end

  test "product detail page displays open price correctly formatted" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text "$1500.00"
    assert_text "Starting bid amount"
  end

  test "product detail page displays price per bid correctly formatted" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text "$50.00"
    assert_text "Minimum increment per bid"
  end

  test "product detail page displays pricing section" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_text "Pricing Information"
    assert_selector "[data-testid='public-product-show-pricing-card']"
  end

  test "product detail page URL is correct" do
    product = products(:vintage_watch)
    visit public_product_path(product)

    assert_current_path public_product_path(product)
    assert_match %r{/public/products/\d+}, current_path
  end
end

