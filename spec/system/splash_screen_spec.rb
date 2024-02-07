# frozen_string_literal: true

require_relative "page_objects/components/splash_screen"

RSpec.describe "Splash screen spec", system: true do
  let!(:theme_component) { upload_theme_component }
  let(:splash_screen) { PageObjects::Components::SplashScreen.new }

  fab!(:user)

  before do
    theme_component.update_translation("slides.slide1", "Slide 1 description")
    theme_component.update_translation("slides.slide2", "Slide 2 description")
    theme_component.update_translation("slides.slide3", "Slide 3 description")
    theme_component.update_translation("slides.heading", "Community")
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
      heading = theme_component.translations.detect {|e| e.key == "slides.heading" }
      slide1 = theme_component.translations.detect {|e| e.key == "slides.slide1" }

      expect(splash_screen).to have_heading(heading.value)
      expect(splash_screen).to have_description(slide1.value)
    end

    it "should change to the next slide when clicking the next button" do
      visit("/")

      heading = theme_component.translations.detect {|e| e.key == "slides.heading" }
      slide1 = theme_component.translations.detect {|e| e.key == "slides.slide1" }
      slide2 = theme_component.translations.detect {|e| e.key == "slides.slide2" }

      expect(splash_screen).to have_heading(heading.value)
      expect(splash_screen).to have_description(slide1.value)
      splash_screen.click_next_button
      expect(splash_screen).to have_description(slide2.value)
    end

    it "should skip to the login page when clicking the skip button" do
      visit("/")
      splash_screen.click_skip_button
      expect(page).to have_css(".login-modal")
      expect(splash_screen).to have_no_splash_screen
    end

    it "should go to the page when clicking on the indicator dot" do
      visit("/")
      heading = theme_component.translations.detect {|e| e.key == "slides.heading" }
      slide3 = theme_component.translations.detect {|e| e.key == "slides.slide3" }

      splash_screen.click_indicator(3)
      expect(splash_screen).to have_heading(heading.value)
      expect(splash_screen).to have_description(slide3.value)
    end

    it "should go to the login page after clicking through all the slides" do
      visit("/")
      # Defaults to 3 slides
      3.times { splash_screen.click_next_button }
      expect(page).to have_css(".login-modal")
      expect(splash_screen).to have_no_splash_screen
    end

    context "when the user has already seen the splash screen" do
      before { visit("/") }

      it "should not show the splash screen" do
        visit("/")

        expect(splash_screen).to have_no_splash_screen
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
