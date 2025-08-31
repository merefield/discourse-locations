import LocationLabelContainer from "./../../components/location-label-container";

<template>
  {{#unless @model.editingTopic}}
    {{#if @model.location}}
      {{#unless this.model.location.hide_marker}}
        <LocationLabelContainer
          @topic={{@model}}
          @location={{@model.location}}
        />
      {{/unless}}
    {{/if}}
  {{/unless}}
</template>
