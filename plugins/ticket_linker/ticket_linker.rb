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
    m.message.scan(match_expression) do |match|
      key   = match.first

      begin
        issue = jira.Issue.find(key)
        m.reply "[#{issue.status.name}] #{issue.summary} https://modolabs.jira.com/browse/#{issue.key}"
      rescue JIRA::HTTPError
      end
    end
  end
end
