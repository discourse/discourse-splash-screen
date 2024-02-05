# frozen_string_literal: true

require_relative "page_objects/components/splash_screen"

RSpec.describe "Splash screen spec", system: true do
  let!(:theme_component) { upload_theme_component }
  let(:splash_screen) { PageObjects::Components::SplashScreen.new }
  let!(:settings_data) { '[{"title":"Welcome to Our App","description":"Explore the amazing features and functionalities of our app.","background_image_url":"https://example.com/background1.jpg"},{"title":"Discover Exciting Possibilities","description":"Dive into a world of innovation and possibilities with our app.","background_image_url":"https://example.com/background2.jpg"},{"title":"Connect with Others","description":"Build meaningful connections and share experiences with our community.","background_image_url":"https://example.com/background3.jpg"},{"title":"Unleash Your Creativity","description":"Express yourself and unleash your creativity using our powerful tools.","background_image_url":"https://example.com/background4.jpg"},{"title":"Ready to Get Started?","description":"Join us now and experience a new level of convenience and excitement.","background_image_url":"https://example.com/background5.jpg"}]' }
  let!(:settings_array) { JSON.parse(settings_data) }
  fab!(:user)

  before do
    theme_component.update_setting(:slide_data, settings_data)
    theme_component.save!
  end

  context "when on desktop mode" do
    context "when user is not logged in" do
      it "should not show the splash screen" do
        visit("/")
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

  context "when user is not logged in", mobile: true do
    it "should show the splash screen" do
      visit("/")
      expect(splash_screen).to have_splash_screen
    end

    it "should show the correct title and description" do
      visit("/")
      expect(splash_screen).to have_heading(settings_array[0]["title"])
      expect(splash_screen).to have_description(settings_array[0]["description"])
    end

    it "should change to the next slide when clicking the next button" do
      visit("/")
      expect(splash_screen).to have_heading(settings_array[0]["title"])
      expect(splash_screen).to have_description(settings_array[0]["description"])
      splash_screen.click_next_button
      expect(splash_screen).to have_heading(settings_array[1]["title"])
      expect(splash_screen).to have_description(settings_array[1]["description"])
    end

    it "should skip to the login page when clicking the skip button" do
      visit("/")
      splash_screen.click_skip_button
      expect(page).to have_css(".login-modal")
      expect(splash_screen).to have_no_splash_screen
    end

    it "should go to the page when clicking on the indicator dot" do
      visit("/")
      splash_screen.click_indicator(3)
      expect(splash_screen).to have_heading(settings_array[2]["title"])
      expect(splash_screen).to have_description(settings_array[2]["description"])
    end

    it "should go to the login page after clicking through all the slides" do
      visit("/")
      5.times { splash_screen.click_next_button }
      expect(page).to have_css(".login-modal")
      expect(splash_screen).to have_no_splash_screen
    end

    context "when the user has already seen the splash screen" do
      before { visit("/") }

      it "should default to the last page of the splash screen" do
        visit("/")

        expect(splash_screen).to have_heading(settings_array[settings_array.length - 1]["title"])
        expect(splash_screen).to have_description(settings_array[settings_array.length - 1]["description"])
      end
    end
  end

  context "when user is logged in", mobile: true do
    before { sign_in(user) }

    it "should not show the splash screen" do
      visit("/")
      expect(splash_screen).to have_no_splash_screen
    end
  end
end
