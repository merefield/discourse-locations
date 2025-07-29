# frozen_string_literal: true

module ::Locations
  class TopicLocation < ActiveRecord::Base
    extend Geocoder::Model::ActiveRecord
    self.table_name = 'locations_topic'

    belongs_to :topic
    validates :longitude, presence: true
    validates :latitude, presence: true
    geocoded_by :address
    after_validation :geocode
    reverse_geocoded_by :latitude, :longitude
    after_validation :reverse_geocode

    def address
      [street, city, state, postalcode, country].compact.join(', ')
    end
  end
end

# == Schema Information
#
# Table name: locations_topic
#
#  id                 :bigint           not null, primary key
#  boundingbox        :float            is an Array
#  city               :string
#  country            :string
#  countrycode        :string
#  district           :string
#  international_code :string
#  latitude           :float            not null
#  locationtype       :string
#  longitude          :float            not null
#  name               :string
#  postalcode         :string
#  state              :string
#  street             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  topic_id           :integer          not null
#
# Indexes
#
#  index_locations_topic_on_topic_id  (topic_id) UNIQUE
#
