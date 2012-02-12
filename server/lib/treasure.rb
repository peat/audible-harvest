class Treasure < ActiveRecord::Base

  def self.provider_data
    providers = {}

    self.all.each do |p|
      providers[p] ||= 0
      providers[p] += 1
    end

    providers.keys.collect { |k| [k, providers[k]] }.to_json
  end

end
