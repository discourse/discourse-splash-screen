import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import SwipeEvents from "discourse/lib/swipe-events";
import DiscourseURL from "discourse/lib/url";
import i18n from "discourse-common/helpers/i18n";
import I18n from "discourse-i18n";

export default class SplashScreen extends Component {
  static shouldRender(outletArgs, helper) {
    if (helper.currentUser || helper.site.desktopView) {
      return false;
    }

    if (
      settings.only_show_mobile_app &&
      window.ReactNativeWebView === undefined
    ) {
      return false;
    }

    return true;
  }

  @service currentUser;
  @service keyValueStore;
  @service siteSettings;

  @tracked currentPage = 1;
  swipeEvents = null;

  constructor() {
    super(...arguments);
    document.documentElement.classList.add("splash-screen-active");
  }

  get pages() {
    return Array.from({ length: settings.number_of_slides }, (v, k) => ({
      description: I18n.t(themePrefix(`slides.slide${k + 1}`)),
    }));
  }

  get currentPageData() {
    return this.pages[this.currentPage - 1];
  }

  get nextButtonLabel() {
    if (this.onLastPage) {
      return I18n.t(themePrefix("actions.finish"));
    } else {
      return I18n.t(themePrefix("actions.next"));
    }
  }

  get onLastPage() {
    return this.currentPage === this.pages.length;
  }

  @action
  goToPage(page) {
    this.currentPage = page + 1;
  }

  @action
  goToPrevious() {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }

  @action
  goToNext() {
    if (this.onLastPage) {
      this.triggerLogin();
    }

    if (this.currentPage < this.pages.length) {
      this.currentPage++;
    }
  }

  @action
  triggerLogin() {
    // perform action via button first
    // route redirection sometimes results in an auth CRSF error
    // Ember routing may skip adding the CSRF token
    const loginButton = document.querySelector(".login-button");
    if (loginButton) {
      loginButton.click();
    } else {
      DiscourseURL.routeTo("/login");
    }

    // if local logins are enabled, we'll be showing a login modal
    // so we can remove the splash screen
    // however, when local logins are disabled, we'll be redirecting
    // it's best to keep the splash screen until the redirect happens
    // otherwise we would be flashing other content for a split second
    if (this.siteSettings.enable_local_logins) {
      document.documentElement.classList.remove("splash-screen-active");
    }
  }

  @action
  pageIsActive(index) {
    return this.currentPage === index + 1 ? "active" : "";
  }

  @action
  handleSwipeEnd(event) {
    if (event.detail.deltaX > 0) {
      this.goToPrevious();
    } else {
      this.goToNext();
    }
  }

  @action
  setupEvents(element) {
    this.swipeEvents = new SwipeEvents(element);
    this.swipeEvents.addTouchListeners();
    element.addEventListener("swipeend", this.handleSwipeEnd);

    if (this.keyValueStore.getItem("seen-splash-screen") === undefined) {
      this.keyValueStore.setItem("seen-splash-screen", true);
    } else if (this.keyValueStore.getItem("seen-splash-screen") === "true") {
      document.documentElement.classList.remove("splash-screen-active");
    }
  }

  teardownEvents(element) {
    this.swipeEvents.removeTouchListeners();
    element.removeEventListener("swipeend", this.handleSwipeEnd);
    document.documentElement.classList.remove("splash-screen-active");
  }

  <template>
    <div
      class="splash-screen"
      data-page={{this.currentPage}}
      {{didInsert this.setupEvents this.pages}}
      {{willDestroy this.teardownEvents this.pages}}
    >
      <div class="splash-screen__image">
      </div>

      <div class="splash-screen__content">
        <h1 class="splash-screen__content__title">{{i18n
            (themePrefix "slides.heading")
          }}</h1>
        <p
          class="splash-screen__content__description"
        >{{this.currentPageData.description}}</p>
      </div>

      <div class="splash-screen__indicators">
        {{#each this.pages as |_ index|}}
          <DButton
            class="btn-transparent {{this.pageIsActive index}}"
            @icon="circle"
            @action={{this.goToPage}}
            @actionParam={{index}}
          />
        {{/each}}
      </div>

      <div class="splash-screen__actions">
        {{#unless this.onLastPage}}
          <DButton
            class="btn-flat splash-screen__actions__skip"
            @translatedLabel={{i18n (themePrefix "actions.skip")}}
            @action={{this.triggerLogin}}
          />
        {{/unless}}

        <DButton
          class="btn-primary splash-screen__actions__next"
          @translatedLabel={{this.nextButtonLabel}}
          @action={{this.goToNext}}
        />
      </div>
    </div>
  </template>
}
