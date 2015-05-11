class Youtube
  include Cinch::Plugin

  match /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/, use_prefix: false, method: :youtube
  def youtube(m, videoid)
    api_key  = config['api_key']
    result = HTTPClient.new.get("https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{videoid}&key=#{api_key}")
    if result.ok?
      json = JSON.parse(result.content)
      if json['items'].size == 1
        item = json['items'].first
        m.reply item['snippet']['title']
      end
    end
  end
end
