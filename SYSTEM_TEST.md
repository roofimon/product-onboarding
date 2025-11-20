# System Tests Guide

This document explains how to run and work with system tests in the ODT Auction Platform.

## Overview

System tests use Capybara and Selenium to test the application through a real browser. They simulate user interactions and verify that the application works correctly from an end-user perspective.

## Prerequisites

### Required Software

1. **Chromium/Chrome Browser**
   - The tests use headless Chrome/Chromium
   - Chromium should be installed at `/usr/bin/chromium-browser` or `/usr/bin/chromium`

2. **ChromeDriver**
   - Required for Selenium to control the browser
   - Should be installed at `/usr/bin/chromedriver`
   - Install via package manager or download from [ChromeDriver downloads](https://chromedriver.chromium.org/)

3. **Ruby and Rails Dependencies**
   - All gems from `Gemfile` (install with `bundle install`)

### Installing ChromeDriver (if needed)

**On Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install chromium-chromedriver
```

**On macOS:**
```bash
brew install chromedriver
```

**Manual Installation:**
1. Download ChromeDriver from https://chromedriver.chromium.org/
2. Extract and place in `/usr/bin/chromedriver`
3. Make it executable: `chmod +x /usr/bin/chromedriver`

## Running System Tests

### Run All System Tests

```bash
bin/rails test:system
```

or

```bash
bin/rails test test/system
```

### Run a Specific Test File

```bash
bin/rails test test/system/public/products_test.rb
```

### Run a Specific Test

```bash
bin/rails test test/system/public/products_test.rb:12
```

Where `12` is the line number where the test is defined.

### Run Tests with Verbose Output

```bash
bin/rails test:system TESTOPTS="--verbose"
```

### Run Tests in Non-Headless Mode (See Browser)

To see the browser during test execution, modify `test/application_system_test_case.rb`:

```ruby
driven_by :selenium, using: :chrome, screen_size: [ 1400, 1400 ] do |driver_options|
  # ... rest of configuration
end
```

Change `:headless_chrome` to `:chrome` to see the browser window.

## Test Structure

### Test Files Location

System tests are located in `test/system/`:

```
test/system/
  └── public/
      └── products_test.rb
```

### Test File Structure

```ruby
require "application_system_test_case"

class PublicProductsTest < ApplicationSystemTestCase
  include ActionView::RecordIdentifier

  setup do
    # Fixtures are automatically loaded
  end

  test "test description" do
    visit root_path
    # ... test code
  end
end
```

## Test Data (Fixtures)

Test data is defined in `test/fixtures/`:

- **Products**: `test/fixtures/products.yml` - Contains 16 sample products
- **Users**: `test/fixtures/users.yml` - Contains sample users (sellers, admin)

Fixtures are automatically loaded before each test runs.

## Common Test Commands

### Navigation

```ruby
visit root_path                    # Navigate to a path
assert_current_path root_path      # Verify current path
```

### Finding Elements

```ruby
find("[data-testid='element-id']")           # Find element by data-testid
assert_selector "[data-testid='element']"   # Assert element exists
all("[data-testid='product-card']")         # Find all matching elements
```

### Form Interactions

```ruby
fill_in "search", with: "Vintage"           # Fill in a form field
select "Price: Low to High", from: "sort-select"  # Select from dropdown
click_button "Search"                       # Click a button
click_link "Next"                           # Click a link
```

### Assertions

```ruby
assert_text "Expected text"                  # Assert text is present
assert_selector "[data-testid='element']"   # Assert element exists
assert_equal expected, actual               # Assert equality
assert_match /pattern/, string              # Assert regex match
```

### Waiting

```ruby
assert_text "Text", wait: 5                 # Wait up to 5 seconds
has_selector?(".element", wait: false)      # Check without waiting
```

## Test Coverage

The current system tests cover:

### Product Listing Page (`test/system/public/products_test.rb`)

- ✅ Product grid layout display
- ✅ Product card information (name, description, seller, pricing)
- ✅ Product images and placeholders
- ✅ Search functionality (exact match, partial match, description search)
- ✅ Empty state when no results
- ✅ Sorting (price low to high, price high to low, newest first)
- ✅ Pagination (navigation, active page highlighting)
- ✅ Product detail page navigation
- ✅ Product detail page content (name, description, seller info, pricing)

## Debugging Tests

### View Test Output

Tests run in headless mode by default. To see what's happening:

1. **Add screenshots**:
```ruby
take_screenshot
```

2. **Add pauses**:
```ruby
sleep 2  # Pause for 2 seconds
```

3. **Print page content**:
```ruby
puts page.html
puts page.text
```

### Common Issues

**Issue: ChromeDriver not found**
```
Solution: Ensure ChromeDriver is installed and accessible at /usr/bin/chromedriver
```

**Issue: Chromium not found**
```
Solution: Install Chromium browser or update paths in test/application_system_test_case.rb
```

**Issue: Element not found**
```
Solution: 
- Check if element has correct data-testid attribute
- Verify element is visible (not hidden)
- Add wait: 5 to assertions for slow-loading content
- Check if element is on a different page (pagination)
```

**Issue: Test timeout**
```
Solution:
- Increase wait times
- Check for JavaScript errors in browser console
- Verify database fixtures are loading correctly
```

## Best Practices

1. **Use data-testid attributes**: Tests use `data-testid` for reliable element selection
2. **Wait for elements**: Use `wait:` parameter for dynamic content
3. **Keep tests independent**: Each test should work in isolation
4. **Use descriptive test names**: Test names should clearly describe what they test
5. **Clean up**: Tests automatically clean up database between runs

## Continuous Integration

System tests can be run in CI/CD pipelines. Ensure:

1. ChromeDriver is installed in CI environment
2. Chromium/Chrome is available
3. Display server is configured (for headless mode)
4. Database is properly set up

Example CI configuration:
```yaml
# .github/workflows/test.yml
- name: Install ChromeDriver
  run: sudo apt-get install -y chromium-chromedriver

- name: Run system tests
  run: bin/rails test:system
```

## Additional Resources

- [Rails System Testing Guide](https://guides.rubyonrails.org/testing.html#system-testing)
- [Capybara Documentation](https://rubydoc.info/github/teamcapybara/capybara/master)
- [Selenium Documentation](https://www.selenium.dev/documentation/)

