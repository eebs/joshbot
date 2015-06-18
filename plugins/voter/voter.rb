class Voter
  include Cinch::Plugin

  match /vote ([\d]+) (.*)/, method: :vote
  match /([\d]+)/, method: :cast_vote, use_prefix: false

  def initialize(*args)
    super
    @voting = false
  end

  def vote(m, seconds, string)
    if @voting
      m.reply "Sorry there's already a vote in progress, please wait until it finishes"
      return
    end

    @voting = true
    @choices = {}
    @votes = Hash.new(0)

    options = string.split(',').each {|choice| choice.strip! }
    options.each_with_index do |choice, index|
      @choices[(index + 1).to_s] = choice
    end

    m.reply "#{m.user.nick} started a vote! Type a number to vote:"
    @choices.each do |key, choice|
      m.reply "#{key}. #{choice}"
    end
    m.reply "Voting will last for #{seconds} seconds"

    @timer = Timer(seconds, shots: 1) do
      @voting = false
      m.reply "Voting ended!"
      max = @votes.max_by {|k, v| v }
      m.reply "'#{@choices[max[0]]}' wins with #{max[1]} votes"
    end
  end

  def cast_vote(m, vote)
    return unless @voting
    return unless @choices.include? vote

    @votes[vote] += 1
  end
end
