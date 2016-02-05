class Stocks
  include Cinch::Plugin

  def initialize(*args)
    super
    @symbols_url = "http://finance.yahoo.com/webservice/v1/symbols/%s/quote?format=json&view=detail"
  end

  match /stock\s*(.+)$/, method: :stock
  def stock(m, symbol)
    url = @symbols_url % symbol
    result = HTTPClient.new.get(url)
    if result.ok?
      symbolDetails = JSON.parse(result.content)
      if symbolDetails['list']['meta']['count'] == 1
        fields = symbolDetails['list']['resources'].first['resource']['fields']
        m.reply CGI.unescapeHTML(fields['name']) +
          ": $%.2f" % fields['price'] +
          " ↕%.2f" % fields['change'] +
            "(%.1f%%)" % fields['chg_percent'] +
          " http://finance.yahoo.com/q?s=#{symbol}"
      end
    end
  end

end
