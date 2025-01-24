<template>
  {{#if @outletArgs.topic.location}}
    <span class="location-after-title">
      <LocationLabelContainer
        @topic={{@outletArgs.topic}}
        @parent="topic-list"
      />
    </span>
  {{/if}}
</template>
