# frozen_string_literal: true

class RemoveGeoLocationFromPublicUserCustomFields < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE site_settings
      SET value = array_to_string(
        array_remove(string_to_array(value, '|'), 'geo_location'),
        '|'
      )
      WHERE name = 'public_user_custom_fields'
        AND 'geo_location' = ANY(string_to_array(value, '|'))
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
