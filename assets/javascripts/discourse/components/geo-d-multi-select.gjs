// plugins/discourse-locations/assets/javascripts/discourse/components/geo-d-multi-select.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { htmlSafe } from "@ember/template";

import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import TextField from "discourse/components/text-field";
import DMenu from "discourse/float-kit/components/d-menu";

import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import element from "discourse/helpers/element";
import discourseDebounce from "discourse/lib/debounce";
import { INPUT_DELAY } from "discourse/lib/environment";
import { makeArray } from "discourse/lib/helpers";
import scrollIntoView from "discourse/modifiers/scroll-into-view";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

class Skeleton extends Component {
  get width() {
    return htmlSafe(`width: ${Math.floor(Math.random() * 70) + 20}%`);
  }

  <template>
    <div class="d-multi-select__skeleton">
      <div class="d-multi-select__skeleton-checkbox" />
      <div class="d-multi-select__skeleton-text" style={{this.width}} />
    </div>
  </template>
}

export default class GeoDMultiSelect extends Component {
  @tracked searchTerm = "";
  @tracked preselectedItem = null;

  // async state (plugin-safe)
  @tracked isPending = false;
  @tracked isResolved = false;
  @tracked isRejected = false;
  @tracked value = null;
  @tracked error = null;

  // when true, the next resolved search will auto-pick first result
  @tracked autoPickNextResult = false;

  compareKey = "id";
  _requestId = 0;

  get hasSelection() {
    return (this.args.selection?.length ?? 0) > 0;
  }

  get label() {
    return this.args.label ?? i18n("multi_select.label");
  }

  get availableOptions() {
    if (!this.isResolved || !this.value) {
      return this.value;
    }

    return this.value.filter(
      (item) =>
        !this.args.selection?.some((selected) => this.compare(item, selected))
    );
  }

  #debouncedSearch() {
    discourseDebounce(
      this,
      this.#performSearch,
      this.args.loadFn,
      this.searchTerm,
      INPUT_DELAY
    );
  }

  @action
  search(event) {
    // normal typing path: DO NOT auto-pick
    this.autoPickNextResult = false;

    this.preselectedItem = null;
    this.searchTerm = event.target.value;
    this.#debouncedSearch();
  }

  @action
  focus(input) {
    this.preselectedItem = null;
    input.focus({ preventScroll: true });
  }

  @action
  setPreselected(item) {
    this.preselectedItem = item;
  }

  @action
  handleKeydown(event) {
    if (!this.isResolved) {
      return;
    }

    if (event.key === "Enter") {
      event.preventDefault();
      event.stopPropagation();

      if (
        this.preselectedItem &&
        this.availableOptions?.some((item) =>
          this.compare(item, this.preselectedItem)
        )
      ) {
        this.toggle(this.preselectedItem, event);
      }
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (!this.availableOptions?.length) return;

      if (this.preselectedItem === null) {
        this.preselectedItem = this.availableOptions[0];
      } else {
        const currentIndex = this.availableOptions.findIndex((item) =>
          this.compare(item, this.preselectedItem)
        );
        if (currentIndex < this.availableOptions.length - 1) {
          this.preselectedItem = this.availableOptions[currentIndex + 1];
        }
      }
    }

    if (event.key === "ArrowUp") {
      event.preventDefault();
      if (!this.availableOptions?.length) return;

      if (this.preselectedItem === null) {
        this.preselectedItem = this.availableOptions[0];
      } else {
        const currentIndex = this.availableOptions.findIndex((item) =>
          this.compare(item, this.preselectedItem)
        );
        if (currentIndex > 0) {
          this.preselectedItem = this.availableOptions[currentIndex - 1];
        }
      }
    }
  }

  @action
  remove(selectedItem, event) {
    event?.stopPropagation();
    this.preselectedItem = null;

    this.args.onChange?.(
      this.args.selection?.filter((item) => !this.compare(item, selectedItem))
    );
  }

  @action
  toggle(result, event) {
    event?.stopPropagation();

    const currentSelection = makeArray(this.args.selection);
    if (currentSelection.some((item) => this.compare(item, result))) {
      return;
    }

    this.preselectedItem = null;
    this.args.onChange?.(currentSelection.concat(result));
  }

  @action
  compare(a, b) {
    if (this.args.compareFn) {
      return this.args.compareFn(a, b);
    } else {
      return a?.[this.compareKey] === b?.[this.compareKey];
    }
  }

  getDisplayText(item) {
    return item?.name;
  }

  // Choose the first "real" location result:
  // - skip provider/footer item (your code adds { provider: ... })
  // - skip anything falsy
  // - skip anything already selected (availableOptions already filters selection, but keep safe)
  #firstSelectableResult() {
    const opts = this.availableOptions || [];
    return opts.find((r) => r && !r.provider);
  }

  #autoPickIfNeeded() {
    if (!this.autoPickNextResult) {
      return;
    }

    // only auto-pick once
    this.autoPickNextResult = false;

    const first = this.#firstSelectableResult();
    if (!first) {
      return;
    }

    // mimic a click selection
    const currentSelection = makeArray(this.args.selection);
    this.args.onChange?.(currentSelection.concat(first));
  }

  #performSearch(loadFn, term) {
    const requestId = ++this._requestId;

    this.isPending = true;
    this.isResolved = false;
    this.isRejected = false;
    this.error = null;

    return Promise.resolve(loadFn?.(term))
      .then((val) => {
        if (requestId !== this._requestId) return;

        this.value = val;
        this.isResolved = true;

        // if bullseye triggered the search, auto-select the first result
        this.#autoPickIfNeeded();
      })
      .catch((e) => {
        if (requestId !== this._requestId) return;
        this.error = e;
        this.isRejected = true;
        // no auto-pick on error
        this.autoPickNextResult = false;
      })
      .finally(() => {
        if (requestId !== this._requestId) return;
        this.isPending = false;
      });
  }

  @action
  useCurrentLocation() {
    if (!navigator.geolocation) {
      return;
    }

    // next search (coords) should auto-pick
    this.autoPickNextResult = true;

    navigator.geolocation.getCurrentPosition(
      ({ coords }) => {
        const term = `${coords.latitude}, ${coords.longitude}`;
        this.preselectedItem = null;
        this.searchTerm = term;

        // run immediately (debounced is fine too, but immediate makes UX snappier)
        this.#performSearch(this.args.loadFn, term);
      },
      () => {
        this.autoPickNextResult = false;
      }
    );
  }

  <template>
    <DMenu
      @identifier="d-multi-select"
      @triggerComponent={{element "div"}}
      @triggerClass={{concatClass (if this.hasSelection "--has-selection")}}
      @visibilityOptimizer={{@visibilityOptimizer}}
      @placement={{@placement}}
      @allowedPlacements={{@allowedPlacements}}
      @offset={{@offset}}
      @matchTriggerMinWidth={{@matchTriggerMinWidth}}
      @matchTriggerWidth={{@matchTriggerWidth}}
      ...attributes
    >
      <:trigger>
        {{#if @selection}}
          <div class="d-multi-select-trigger__selection">
            {{#each @selection as |item|}}
              <button
                class="d-multi-select-trigger__selected-item"
                {{on "click" (fn this.remove item)}}
                title={{this.getDisplayText item}}
              >
                <span class="d-multi-select-trigger__selection-label">
                  {{yield item to="selection"}}
                </span>
                {{icon
                  "xmark"
                  class="d-multi-select-trigger__remove-selection-icon"
                }}
              </button>
            {{/each}}
          </div>
        {{else}}
          <span class="d-multi-select-trigger__label">{{this.label}}</span>
        {{/if}}

        {{!-- bullseye: auto-picks first result from coords --}}
        <DButton
          @icon="bullseye"
          class="btn btn-default location-current-btn"
          @action={{this.useCurrentLocation}}
        />

        <DButton
          @icon="angle-down"
          class="d-multi-select-trigger__expand-btn btn-transparent"
          @action={{@componentArgs.show}}
        />
      </:trigger>

      <:content>
        <DropdownMenu class="d-multi-select__content" as |menu|>
          <menu.item class="d-multi-select__search-container">
            {{icon "magnifying-glass"}}
            <TextField
              class="d-multi-select__search-input"
              autocomplete="off"
              @placeholder={{i18n "multi_select.search"}}
              @type="search"
              {{on "input" this.search}}
              {{on "keydown" this.handleKeydown}}
              {{didInsert this.focus}}
              @value={{readonly this.searchTerm}}
            />
          </menu.item>

          <menu.divider />

          {{#if this.isPending}}
            <div class="d-multi-select__skeletons">
              <Skeleton />
              <Skeleton />
              <Skeleton />
              <Skeleton />
              <Skeleton />
            </div>
          {{else if this.isRejected}}
            <div class="d-multi-select__error">
              {{yield this.error to="error"}}
            </div>
          {{else if this.isResolved}}
            {{#if this.availableOptions.length}}
              <div class="d-multi-select__search-results">
                {{#each this.availableOptions as |result|}}
                  <menu.item
                    class={{concatClass
                      "d-multi-select__result"
                      (if (eq result this.preselectedItem) "--preselected" "")
                    }}
                    role="button"
                    title={{this.getDisplayText result}}
                    {{scrollIntoView (eq result this.preselectedItem)}}
                    {{on "mouseenter" (fn this.setPreselected result)}}
                    {{on "click" (fn this.toggle result)}}
                  >
                    <span class="d-multi-select__result-label">
                      {{yield result to="result"}}
                    </span>
                  </menu.item>
                {{/each}}
              </div>
            {{else}}
              <div class="d-multi-select__search-no-results">
                {{i18n "multi_select.no_results"}}
              </div>
            {{/if}}
          {{/if}}
        </DropdownMenu>
      </:content>
    </DMenu>
  </template>
}
