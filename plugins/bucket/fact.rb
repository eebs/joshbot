class Fact < ActiveRecord::Base
  validates :fact, presence: true
  validates :tidbit, presence: true
  validates :verb, presence: true

  def self.slug(fact)
    fact.downcase.gsub(/[^a-z0-9\s]/i, '')
  end

  def self.random(fact)
    slug = slug(fact)
    ids = where(fact: slug).pluck(:id)
    return if ids.empty?
    find(ids.sample)
  end
end
