class TicketLinker
  include Cinch::Plugin

  attr_reader :jira
  attr_reader :match_expression

  def initialize(*args)
    super

    @jira = jira_client

    project_keys = projects.collect { |p| p.key }
    @match_expression = /((?:#{project_keys.join('|')})-\d+)/i
  end

  def jira_client
    options = {
      :username     => config['username'],
      :password     => config['password'],
      :site         => config['site'],
      :context_path => config['context_path'],
      :auth_type    => :basic
    }

    client = JIRA::Client.new(options)
  end

  def projects
    jira.Project.all
  end

  listen_to :message

  def listen(m)
    matched = false
    m.message.scan(match_expression) do |match|
      key   = match.first

      begin
        issue = jira.Issue.find(key)

        assignee = issue.assignee ? issue.assignee.displayName : 'Unassigned'
        reporter = issue.reporter.displayName

        m.reply "*#{issue.key}*: #{issue.summary} https://modolabs.jira.com/browse/#{issue.key} _#{issue.status.name}: #{assignee} via #{reporter}_"
      rescue JIRA::HTTPError
      end
      matched = true
    end

    if matched
      if m.user.nick == 'zrice57'
        w = Wunderground.new(config['wunderground'])
        response = w.conditions_for('MA', 'Boston')
        begin
          pressure = response['current_observation']['pressure_in']
          m.reply "Current pressure is #{pressure}"
        rescue Exception
        end
      end
    end
  end
end
