import LocationLabelContainer from './../../components/location-label-container';

<template>
  {{#unless this.model.editingTopic}}
    {{#if this.model.location}}
      {{#unless this.model.location.hide_marker}}
        <LocationLabelContainer
          @topic={{this.model}}
          @location={{this.model.location}}
        />
      {{/unless}}
    {{/if}}
  {{/unless}}
</template>
