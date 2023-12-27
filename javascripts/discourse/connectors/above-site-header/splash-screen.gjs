import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import SwipeEvents from "discourse/lib/swipe-events";
import DiscourseURL from "discourse/lib/url";
import i18n from "discourse-common/helpers/i18n";
import I18n from "discourse-i18n";

export default class SplashScreen extends Component {
  static shouldRender(outletArgs, helper) {
    if (helper.currentUser) {
      return false;
    }

    return true;
  }

  @service currentUser;
  @service keyValueStore;
  @tracked currentPage = 1;
  swipeEvents = null;

  constructor() {
    super(...arguments);
    document.documentElement.classList.add("splash-screen-active");

    if (this.keyValueStore.getItem("seen-splash-screen") === undefined) {
      this.keyValueStore.setItem("seen-splash-screen", true);
    } else if (this.keyValueStore.getItem("seen-splash-screen") === "true") {
      this.skipSplashScreen();
    }
  }

  get pages() {
    try {
      const parsedData = JSON.parse(settings.slide_data);
      return parsedData;
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error parsing JSON:", error);
    }
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
      this.skipSplashScreen();
    }

    if (this.currentPage < this.pages.length) {
      this.currentPage++;
    }
  }

  @action
  skipSplashScreen() {
    document.documentElement.classList.remove("splash-screen-active");
    DiscourseURL.routeTo("/login");
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
  }

  teardownEvents(element) {
    this.swipeEvents.removeTouchListeners();
    element.removeEventListener("swipeend", this.handleSwipeEnd);
    document.documentElement.classList.remove("splash-screen-active");
  }

  <template>
    <div
      class="splash-screen"
      {{didInsert this.setupEvents this.pages}}
      {{willDestroy this.teardownEvents this.pages}}
    >
      {{#if this.currentPageData.background_image_url}}
        <div class="splash-screen__image">
          <img src={{this.currentPageData.background_image_url}} />
        </div>
      {{/if}}

      <div class="splash-screen__content">
        <h1
          class="splash-screen__content__title"
        >{{this.currentPageData.title}}</h1>
        <p
          class="splash-screen__content__description"
        >{{this.currentPageData.description}}</p>
      </div>

      <div class="splash-screen__indicators">
        {{#each this.pages as |page index|}}
          <DButton
            @class="btn-transparent {{this.pageIsActive index}}"
            @icon="circle"
            @action={{this.goToPage}}
            @actionParam={{index}}
          />
        {{/each}}
      </div>

      <div class="splash-screen__actions">
        {{#unless this.onLastPage}}
          <DButton
            @class="btn-flat splash-screen__actions__skip"
            @translatedLabel={{i18n (themePrefix "actions.skip")}}
            @action={{this.skipSplashScreen}}
          />
        {{/unless}}

        <DButton
          @class="btn-primary splash-screen__actions__next"
          @translatedLabel={{this.nextButtonLabel}}
          @action={{this.goToNext}}
        />
      </div>
    </div>
  </template>
}
