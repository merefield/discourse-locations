import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  classNames: ['location-label-user-container'],

  @computed('user.custom_fields.geo_location.geo_location')
  showMapToggle(geoLocation) {
    return geoLocation && this.siteSettings.location_topic_map;
  },

  didInsertElement() {
    Ember.$(document).on('click', Ember.run.bind(this, this.outsideClick));
  },

  willDestroyElement() {
    Ember.$(document).off('click', Ember.run.bind(this, this.outsideClick));
  },

  outsideClick(e) {
    if (!this.isDestroying && !$(e.target).closest('.location-user-map').length) {
      this.set('showMap', false);
    }
  },

  actions: {
    showMap() {
      this.toggleProperty('showMap');
    }
  }
});
