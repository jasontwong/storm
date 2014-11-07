require_relative "apps/storm"

map('/v0') { run Storm::V0 }
