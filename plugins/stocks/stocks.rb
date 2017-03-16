class Stocks
  include Cinch::Plugin

  def initialize(*args)
    super
    @symbols_url = "http://finance.google.com/finance/info?client=ig&q=%s"
  end

  match /stock\s*(.+)$/, method: :stock
  def stock(m, symbols)
    output = ''
    symbols.gsub! " ",""
    url = @symbols_url % symbols
    result = HTTPClient.new.get(url)
    if result.ok?
      result.content.sub! "//","" #google leads response with comment
      symbolDetails = JSON.parse(result.content)
      if symbolDetails.length >= 1
        symbolDetails.each do |fields|
          m.reply CGI.unescapeHTML(fields['t']) + #ticker
            ": $%s ↕" % fields['l'] + #last price
            fields['c'] + #change
            "(%s%%)" % fields['cp'] + #change percent
            " http://google.com/finance?q=#{fields['e']}%3A#{fields['t']}\n"
        end
      else
        m.reply "No ticker found for symbol: #{symbols}\n"
      end
    else
      m.reply "No ticker found for symbol: #{symbols}\n"
    end
  end

end
