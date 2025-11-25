require "test_helper"
require "selenium/webdriver"

# Configure ChromeDriver path before Selenium initializes
if File.exist?("/usr/bin/chromedriver")
  Selenium::WebDriver::Chrome::Service.driver_path = "/usr/bin/chromedriver"
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_options|
    driver_options.add_argument("--no-sandbox")
    driver_options.add_argument("--disable-dev-shm-usage")
    driver_options.add_argument("--disable-gpu")

    # Use Chromium browser
    chromium_path = "/usr/bin/chromium-browser"
    if File.exist?(chromium_path)
      driver_options.binary = chromium_path
    elsif File.exist?("/usr/bin/chromium")
      driver_options.binary = "/usr/bin/chromium"
    end
  end
end
