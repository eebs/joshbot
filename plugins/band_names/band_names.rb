class BandNames
  include Cinch::Plugin

  listen_to :channel
  def listen(m)
    words = m.message.split(/\s+/)

    return unless words.count == 3
    return unless words.all? {|word| word.gsub(/[^a-z]/i, '').length >= 4}

    prng = Random.new
    if prng.rand(100) < 5
      m.reply phrases.sample.sub('%s', m.message)
    end
  end

  def phrases
    [
      '"%s" would be a good name for a band.',
      '"%s" would be a nice name for a band.',
      '"%s" would be a nice name for a rock band.',
      '"%s" would make a good name for a band.',
      '"%s" would make a good name for a rock band.',
    ]
  end
end
