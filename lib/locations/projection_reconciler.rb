# frozen_string_literal: true

module ::Locations
  class ProjectionReconciler
    def self.reconcile
      { users: reconcile_users, topics: reconcile_topics }
    end

    def self.reconcile_users
      source_ids =
        UserCustomField.where(
          name: UserLocationStore::FIELD_NAME,
          user_id: User.select(:id)
        ).select(:user_id)
      results = Hash.new(0)

      User
        .where(id: source_ids)
        .find_each { |user| results[UserLocationStore.sync(user)] += 1 }
      results[:deleted] += UserLocation
        .where.not(user_id: source_ids)
        .delete_all

      results
    end

    def self.reconcile_topics
      source_ids =
        TopicCustomField.where(
          name: TopicLocationStore::FIELD_NAME,
          topic_id: Topic.select(:id)
        ).select(:topic_id)
      results = Hash.new(0)

      Topic
        .where(id: source_ids)
        .find_each { |topic| results[TopicLocationStore.sync(topic)] += 1 }
      results[:deleted] += TopicLocation
        .where.not(topic_id: source_ids)
        .delete_all

      results
    end
  end
end
