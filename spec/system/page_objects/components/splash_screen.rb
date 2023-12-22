# frozen_string_literal: true

module PageObjects
  module Components
    class SplashScreen < PageObjects::Components::Base
      SPLASH_SCREEN_SELECTOR = ".splash-screen"
      CONTENT_SELECTOR = "#{SPLASH_SCREEN_SELECTOR}__content"
      INDICATORS_SELECTOR = "#{SPLASH_SCREEN_SELECTOR}__indicators"
      ACTIONS_SELECTOR = "#{SPLASH_SCREEN_SELECTOR}__actions"

      def click_next_button
        find("#{ACTIONS_SELECTOR} .splash-screen__actions__next").click
      end

      def click_skip_button
        find("#{ACTIONS_SELECTOR} .splash-screen__actions__skip").click
      end

      def click_indicator(index)
        find("#{INDICATORS_SELECTOR} .btn:nth-child(#{index})").click
      end

      def has_splash_screen?
        page.has_css?(SPLASH_SCREEN_SELECTOR)
      end

      def has_no_splash_screen?
        page.has_no_css?(SPLASH_SCREEN_SELECTOR)
      end

      def has_heading?(title)
        page.find("#{CONTENT_SELECTOR}__title").text == title
      end

      def has_description?(description)
        page.find("#{CONTENT_SELECTOR}__description").text == description
      end
    end
  end
end
