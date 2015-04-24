class Bucket
  include Cinch::Plugin

  set :prefix, lambda { |m| Regexp.new("^@?#{m.bot.nick}: ") }

  match /(.{4,}) is (.{4,})/,         method: :x_is_y,      group: :bucket
  match /(.{4,}) \<reply\> (.{4,})/,  method: :x_reply_y,   group: :bucket
  match /(.{4,}) \<action\> (.{4,})/, method: :x_action_y,  group: :bucket

  match //,                           method: :check_facts, group: :bucket, use_prefix: false, use_suffix: false,

  def x_is_y(m, fact, tidbit)
    fact = Fact.create(fact: Fact.slug(fact), tidbit: tidbit, verb: 'is')
    m.reply "Okay, #{m.user.nick}"
  end

  def x_reply_y(m, fact, tidbit)
    fact = Fact.create(fact: Fact.slug(fact), tidbit: tidbit, verb: '<reply>')
    m.reply "Okay, #{m.user.nick}"
  end

  def x_action_y(m, fact, tidbit)
    fact = Fact.create(fact: Fact.slug(fact), tidbit: tidbit, verb: '<action>')
    m.reply "Okay, #{m.user.nick}"
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
end
