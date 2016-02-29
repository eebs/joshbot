class Stocks
  include Cinch::Plugin

  def initialize(*args)
    super
    @symbols_url = "http://finance.yahoo.com/webservice/v1/symbols/%s/quote?format=json&view=detail"
  end

  match /stock\s*(.+)$/, method: :stock
  def stock(m, symbols)
    output = ''
    symbols.split(",").each do |symbol|
      symbol.strip!
      url = @symbols_url % symbol
      result = HTTPClient.new.get(url)
      if result.ok?
        symbolDetails = JSON.parse(result.content)
        if symbolDetails['list']['meta']['count'] == 1
          fields = symbolDetails['list']['resources'].first['resource']['fields']
          output += CGI.unescapeHTML(fields['issuer_name']) +
            ": $%.2f" % fields['price'] +
            " ↕%.2f" % fields['change'] +
              "(%.1f%%)" % fields['chg_percent'] +
            " http://finance.yahoo.com/q?s=#{symbol}\n"
        else
          output += "No ticker found for symbol: #{symbol}\n"
        end
      end
    end
    m.reply output
  end

end
