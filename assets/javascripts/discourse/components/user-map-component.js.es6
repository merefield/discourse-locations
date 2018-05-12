import MountWidget from 'discourse/components/mount-widget';
import { observes, on } from 'ember-addons/ember-computed-decorators';

export default MountWidget.extend({
  classNames: 'map-component',
  widget: 'user-map',
  clickable: false,

  buildArgs() {
    let args = this.getProperties(
      'user',
      'locations',
      'clickable',
      'userList',
      'search',
      'showAvatar',
      'size',
      'center',
      'zoom'
    );

    console.log("buildArgs here");

    if (this.get('custom_fields.geo_location.geo_location')) {
      if (!args['locations']) args['locations'] = [];
      args['locations'].push({ geo_location: this.get('custom_fields.geo_location.geo_location') });
    }

    return args;
  },

  @on('didInsertElement')
  setupOnRender() {
    this.scheduleSetup();
  },

  @observes('user','geoLocation','geoLocations.[]')
  refreshMap() {
    this.queueRerender();
    this.scheduleSetup();
  },

  scheduleSetup() {
    Ember.run.scheduleOnce('afterRender', () => {
      this.appEvents.trigger('dom:clean');
    });
  }
});
