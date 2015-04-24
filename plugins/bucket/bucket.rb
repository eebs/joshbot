class Bucket
  include Cinch::Plugin

  set :prefix, lambda { |m| Regexp.new("^@?#{m.bot.nick}: ") }

  match /(.+) \<reply\> (.+)/,  method: :x_reply_y,   group: :bucket
  match /(.+) \<action\> (.+)/, method: :x_action_y,  group: :bucket
  match /(.+) \<(.+)\> (.+)/,   method: :x_verb_y,    group: :bucket
  match /(.+) is (.+)/,         method: :x_is_y,      group: :bucket

  match //,                     method: :check_facts, group: :bucket, use_prefix: false, use_suffix: false

  def initialize(*args)
    super

    @minimum_trigger_length = config[:minimum_trigger_length] || 6
  end

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
    return unless should_respond?(m)
    return unless fact = Fact.random(fact_for_message(m))

    case fact.verb
    when '<reply>'
      m.reply "#{fact.tidbit}"
    when '<action>'
      m.action_reply "#{fact.tidbit}"
    else
      m.reply "#{fact.fact} #{fact.verb} #{fact.tidbit}"
    end
  end

  private

  def should_respond?(m)
    if m.action?
      m.action_message.length >= @minimum_trigger_length
    else
      # If the message is prefixed with the bot's name always respond
      if /^@?#{m.bot.nick}: / =~ m.message
        true
      else
        m.message.length >= @minimum_trigger_length
      end
    end
  end

  def fact_for_message(m)
    if m.action?
      m.action_messages
    else
      # If the message is prefixed with the bot's name, return the actual message
      /^@?#{m.bot.nick}: (.*)/.match(m.message) do |match|
        return match.captures.first
      end
      m.message
    end
  end
end
