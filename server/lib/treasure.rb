class Treasure < ActiveRecord::Base

  def first_person?
    people = Treasure.where('person=?', person).order('id')
    (people.count > 1 and people.first == self)
  end

  def first_track?
    tracks = Treasure.where('artist=? AND track=?', artist, track).order('id')
    (tracks.count > 1 and tracks.first == self)
  end

  def first_artist?
    tracks = Treasure.where('artist=?', artist).order('id')
    (tracks.count > 1 and tracks.first == self)
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

  def self.top_people
    people = {}

    self.all.each do |t|
      people[t.person] ||= 0
      people[t.person] += 1
    end

    # only return the top 5 ...
    people.keys.collect { |k| [k, people[k]] }.sort { |a,b| b[1] <=> a[1] }.slice(0,5)
  end

  def self.top_artists
    artists = {}

    self.all.each do |t|
      artists[t.artist] ||= 0
      artists[t.artist] += 1
    end

    # only return the top 5 ...
    artists.keys.collect { |k| [k, artists[k]] }.sort { |a,b| b[1] <=> a[1] }.slice(0,5)
  end

end
