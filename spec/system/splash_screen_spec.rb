# frozen_string_literal: true

require_relative "page_objects/components/splash_screen"

RSpec.describe "Splash screen spec", system: true do
  let!(:theme_component) { upload_theme_component }
  let(:splash_screen) { PageObjects::Components::SplashScreen.new }
  fab!(:user)

  before do
    settings_data =
      '[{"title":"Welcome to Our App","description":"Explore the amazing features and functionalities of our app.","background_image_url":"https://example.com/background1.jpg"},{"title":"Discover Exciting Possibilities","description":"Dive into a world of innovation and possibilities with our app.","background_image_url":"https://example.com/background2.jpg"},{"title":"Connect with Others","description":"Build meaningful connections and share experiences with our community.","background_image_url":"https://example.com/background3.jpg"},{"title":"Unleash Your Creativity","description":"Express yourself and unleash your creativity using our powerful tools.","background_image_url":"https://example.com/background4.jpg"},{"title":"Ready to Get Started?","description":"Join us now and experience a new level of convenience and excitement.","background_image_url":"https://example.com/background5.jpg"}]'
    theme_component.update_setting(:slide_data, settings_data)
    theme_component.save!
  end

  context "when user is not logged in" do
    it "should show the splash screen" do
      visit("/")
      expect(splash_screen).to have_splash_screen
    end

    it "should show the correct title and description" do
      slide_1_title = "Welcome to Our App"
      slide_1_description =
        "Explore the amazing features and functionalities of our app."
      visit("/")
      expect(splash_screen).to have_heading(slide_1_title)
      expect(splash_screen).to have_description(slide_1_description)
    end

    it "should change to the next slide when clicking the next button" do
      slide_1_title = "Welcome to Our App"
      slide_1_description =
        "Explore the amazing features and functionalities of our app."
      slide_2_title = "Discover Exciting Possibilities"
      slide_2_description =
        "Dive into a world of innovation and possibilities with our app."

      visit("/")
      expect(splash_screen).to have_heading(slide_1_title)
      expect(splash_screen).to have_description(slide_1_description)
      splash_screen.click_next_button
      expect(splash_screen).to have_heading(slide_2_title)
      expect(splash_screen).to have_description(slide_2_description)
    end

    it "should skip to the last slide when clicking the skip button" do
      final_title = "Ready to Get Started?"
      final_description =
        "Join us now and experience a new level of convenience and excitement."

      visit("/")
      splash_screen.click_skip_button
      expect(splash_screen).to have_heading(final_title)
      expect(splash_screen).to have_description(final_description)
    end

    it "should go to the page when clicking on the indicator dot" do
      slide_3_title = "Connect with Others"
      slide_3_description =
        "Build meaningful connections and share experiences with our community."

      visit("/")
      splash_screen.click_indicator(3)
      expect(splash_screen).to have_heading(slide_3_title)
      expect(splash_screen).to have_description(slide_3_description)
    end

    it "should go to the login page after clicking through all the slides" do
      visit("/")
      splash_screen.click_skip_button
      splash_screen.click_next_button
      expect(page).to have_css(".login-modal")
      expect(splash_screen).to have_no_splash_screen
    end
  end

  context "when user is logged in" do
    before { sign_in(user) }

    it "should not show the splash screen" do
      visit("/")
      expect(splash_screen).to have_no_splash_screen
    end
  end
end
