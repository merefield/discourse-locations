# frozen_string_literal: true
class RemoveHasGeoLocationTopicCustomFields < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DELETE FROM topic_custom_fields
      WHERE name = 'has_geo_location'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
