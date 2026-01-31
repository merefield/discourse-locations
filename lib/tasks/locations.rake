# frozen_string_literal: true
desc "Update location table for each user"
task "locations:refresh_user_location_table",
     %i[missing_only delay] => :environment do |_, args|
  if ENV["RAILS_DB"]
    refresh_user_location_table(args)
  else
    refresh_user_location_table_all_sites(args)
  end
end

def refresh_user_location_table_all_sites(args)
  RailsMultisite::ConnectionManagement.each_connection do |db|
    refresh_user_location_table(args)
  end
end

def refresh_user_location_table(args)
  puts "-" * 50
  puts "Refreshing data for user locations for '#{RailsMultisite::ConnectionManagement.current_db}'"
  puts "-" * 50

  missing_only = args[:missing_only]&.to_i
  delay = args[:delay]&.to_i

  puts "for missing only" if !missing_only.to_i.zero?
  if !delay.to_i.zero?
    puts "with a delay of #{delay} second(s) between API calls"
  end
  puts "-" * 50

  if delay && delay < 1
    puts "ERROR: delay parameter should be an integer and greater than 0"
    exit 1
  end

  begin
    total = User.count
    refreshed = 0
    batch = 1000

    (0..(total - 1).abs).step(batch) do |i|
      User
        .order(id: :desc)
        .offset(i)
        .limit(batch)
        .each do |user|
          if !missing_only.to_i.zero? &&
               ::Locations::UserLocation.find_by(user_id: user.id).nil? ||
               missing_only.to_i.zero?
            Locations::UserLocationProcess.upsert(user.id)
            sleep(delay) if delay
          end
          print_status(refreshed += 1, total)
        end
    end
  end

  puts "", "#{refreshed} users done!", "-" * 50
end

desc "Update locations table for each topic"
task "locations:refresh_topic_location_table",
     %i[missing_only delay] => :environment do |_, args|
  if ENV["RAILS_DB"]
    refresh_topic_location_table(args)
  else
    refresh_topic_location_table_all_sites(args)
  end
end

def refresh_topic_location_table_all_sites(args)
  RailsMultisite::ConnectionManagement.each_connection do |db|
    refresh_topic_location_table(args)
  end
end

def refresh_topic_location_table(args)
  puts "-" * 50
  puts "Refreshing data for topic locations for '#{RailsMultisite::ConnectionManagement.current_db}'"
  puts "-" * 50

  missing_only = args[:missing_only]&.to_i
  delay = args[:delay]&.to_i

  puts "for missing only" if !missing_only.to_i.zero?
  if !delay.to_i.zero?
    puts "with a delay of #{delay} second(s) between API calls"
  end
  puts "-" * 50

  if delay && delay < 1
    puts "ERROR: delay parameter should be an integer and greater than 0"
    exit 1
  end

  begin
    total = Topic.count
    refreshed = 0
    batch = 1000

    (0..(total - 1).abs).step(batch) do |i|
      Topic
        .order(id: :desc)
        .offset(i)
        .limit(batch)
        .each do |topic|
          if !missing_only.to_i.zero? &&
               ::Locations::TopicLocation.find_by(topic_id: topic.id).nil? ||
               missing_only.to_i.zero?
            Locations::TopicLocationProcess.upsert(topic)
            sleep(delay) if delay
          end
          print_status(refreshed += 1, total)
        end
    end
  end

  puts "", "#{refreshed} topics done!", "-" * 50
end

desc "Enqueue IP-based user location lookups (see locations:enqueue_user_ip_location_lookups:help)"
task "locations:enqueue_user_ip_location_lookups",
     %i[username_pattern pattern_type delay] => :environment do |_, args|
  if ENV["RAILS_DB"]
    enqueue_user_ip_location_lookups(args)
  else
    enqueue_user_ip_location_lookups_all_sites(args)
  end
end

desc "Show help for locations:enqueue_user_ip_location_lookups"
task "locations:enqueue_user_ip_location_lookups:help" => :environment do
  puts <<~TEXT
    Usage:
      rake locations:enqueue_user_ip_location_lookups[username_pattern,pattern_type,delay]

    Description:
      Enqueues Jobs::Locations::IpLocationLookup for users using their last recorded IP (user.ip_address).

    Options:
      username_pattern  Optional. Filter users by username.
                        - pattern_type=string: substring match (default)
                        - pattern_type=regex: Ruby regex applied to username
      pattern_type      Optional. "string" or "regex" (default: string)
      delay             Optional. Seconds to sleep between enqueues (float, default: 0)

    Examples:
      rake locations:enqueue_user_ip_location_lookups
      rake locations:enqueue_user_ip_location_lookups[alice,string,0.5]
      rake locations:enqueue_user_ip_location_lookups["^staff_",regex,0.1]
  TEXT
end

def enqueue_user_ip_location_lookups_all_sites(args)
  RailsMultisite::ConnectionManagement.each_connection do |_db|
    enqueue_user_ip_location_lookups(args)
  end
end

def enqueue_user_ip_location_lookups(args)
  puts "-" * 50
  puts "Enqueuing IP-based user location lookups for '#{RailsMultisite::ConnectionManagement.current_db}'"
  puts "-" * 50

  pattern = args[:username_pattern]
  pattern_type = args[:pattern_type]&.downcase || "string"
  delay = args[:delay]&.to_f

  if pattern_type != "string" && pattern_type != "regex"
    puts "ERROR: pattern_type must be 'string' or 'regex'"
    exit 1
  end

  if delay && delay < 0
    puts "ERROR: delay parameter should be a number and zero or greater"
    exit 1
  end

  puts "username pattern: #{pattern} (#{pattern_type})" if pattern.present?
  puts "with a delay of #{delay} second(s) between enqueues" if delay.to_f > 0
  puts "-" * 50

  relation = User.all
  if pattern.present?
    if pattern_type == "regex"
      relation = relation.where("username ~* ?", pattern)
    else
      relation = relation.where("username ILIKE ?", "%#{pattern}%")
    end
  end

  total = relation.count
  queued = 0
  batch = 1000

  (0..(total - 1).abs).step(batch) do |i|
    relation
      .order(id: :desc)
      .offset(i)
      .limit(batch)
      .each do |user|
        ip_address = user.ip_address&.to_s
        if ip_address.present?
          Jobs.enqueue(
            ::Jobs::Locations::IpLocationLookup,
            user_id: user.id,
            ip_address: ip_address
          )
        end
        print_status(queued += 1, total)
        sleep(delay) if delay.to_f > 0
      end
  end

  puts "", "#{queued} users queued!", "-" * 50
end
