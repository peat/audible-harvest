class Treasure < ActiveRecord::Base

  def first_track?
    (Treasure.where('track=? AND artist=? AND min(id)=?', track, artist, id ).count > 1 )
  end

  def first_artist?
    (Treasure.where('artist=? AND min(id)=?', artist, id ).count > 1 )
  end

  def self.provider_data
    providers = {}

    self.all.each do |t|
      providers[t.provider] ||= 0
      providers[t.provider] += 1
    end

    providers.keys.collect { |k| [k, providers[k]] }.sort { |a,b| b[1] <=> a[1] }.to_json
  end

  def self.origin_data
    origins = {}

    self.all.each do |t|
      origins[t.origin] ||= 0
      origins[t.origin] += 1
    end

    origins.keys.collect { |k| [k, origins[k]] }.sort { |a,b| b[1] <=> a[1] }.to_json
  end

  def self.people_data
    people = {}

    self.all.each do |t|
      people[t.person] ||= 0
      people[t.person] += 1
    end

    # only return the top 5 ...
    people.keys.collect { |k| [k, people[k]] }.sort { |a,b| b[1] <=> a[1] }.slice(0,5).to_json
  end

end
