# frozen_string_literal: true
class CreateLocationsTopicIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :locations_topic,
              %i[latitude longitude],
              name: "composite_index_on_locations_topic"
  end
end
