# frozen_string_literal: true

desc "Reconcile canonical location data with the spatial projection tables"
task "locations:reconcile_location_tables" => :environment do
  reconcile = -> do
    database = RailsMultisite::ConnectionManagement.current_db
    results = Locations::ProjectionReconciler.reconcile
    puts "Reconciled locations for '#{database}': #{results.inspect}"
  end

  if ENV["RAILS_DB"]
    reconcile.call
  else
    RailsMultisite::ConnectionManagement.each_connection { reconcile.call }
  end
end
