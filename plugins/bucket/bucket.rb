class Bucket
  include Cinch::Plugin

  set :prefix, lambda { |m| Regexp.new("^@?#{m.bot.nick}: ") }

  match /(.+) \<reply\> (.+)/,  method: :x_reply_y,   group: :bucket
  match /(.+) \<action\> (.+)/, method: :x_action_y,  group: :bucket
  match /(.+) \<(.+)\> (.+)/,   method: :x_verb_y,    group: :bucket
  match /(.+) is (.{3,})/,         method: :x_is_y,      group: :bucket

  match //,                           method: :check_facts, group: :bucket, use_prefix: false, use_suffix: false

  def x_is_y(m, fact, tidbit)
    fact = Fact.new(fact: Fact.slug(fact), tidbit: tidbit, verb: 'is')
    if fact.save
      m.reply "Okay, #{m.user.nick}"
    else
      m.reply "Nope"
    end
  end

  def x_reply_y(m, fact, tidbit)
    fact = Fact.new(fact: Fact.slug(fact), tidbit: tidbit, verb: '<reply>')
    if fact.save
      m.reply "Okay, #{m.user.nick}"
    else
      m.reply "Nope"
    end
  end

  def x_action_y(m, fact, tidbit)
    fact = Fact.new(fact: Fact.slug(fact), tidbit: tidbit, verb: '<action>')
    if fact.save
      m.reply "Okay, #{m.user.nick}"
    else
      m.reply "Nope"
    end
  end

  def x_verb_y(m, fact, verb, tidbit)
    fact = Fact.new(fact: Fact.slug(fact), tidbit: tidbit, verb: verb)
    if fact.save
      m.reply "Okay, #{m.user.nick}"
    else
      m.reply "Nope"
    end
  end

  def check_facts(m)
    debug m.inspect

    factoid = m.action? ? m.action_message : m.message
    return unless factoid

    slug = Fact.slug(factoid)
    return unless fact = Fact.random(slug)

    case fact.verb
    when '<reply>'
      m.reply "#{fact.tidbit}"
    when '<action>'
      m.action_reply "#{fact.tidbit}"
    else
      m.reply "#{fact.fact} #{fact.verb} #{fact.tidbit}"
    end
  end

  listen_to :message
  def listen(m)
    debug m.inspect
  end
end
