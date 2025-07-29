# frozen_string_literal: true

module ::Locations
  class UserLocation < ActiveRecord::Base
    extend Geocoder::Model::ActiveRecord
    self.table_name = 'locations_user'

    belongs_to :user
    validates :user_id, presence: true, uniqueness: true
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
# Table name: locations_user
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
#  postalcode         :string
#  state              :string
#  street             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_locations_user_on_user_id  (user_id) UNIQUE
#
