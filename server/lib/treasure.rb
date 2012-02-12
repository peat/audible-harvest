class Treasure < ActiveRecord::Base
  def pretty_print
    [ id, created_at, person, track, artist, provider, origin ].join(" :: ")
  end
end
