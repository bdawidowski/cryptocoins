require "cryptocoins/version"
require 'httparty'
require 'open-uri'
require 'phantomjs'
module CryptoCoins
  def.initialize
    Phantomjs.path
  end
  class Coin
    def self.top(limit)
      options = {query: { limit: limit.to_s}}
      return HTTParty.get('https://api.coinmarketcap.com/v1/ticker/?', options)
    end
    def self.find(ticker)
      response = HTTParty.get('https://api.coinmarketcap.com/v1/ticker/')
      response.each do |coin|
        if coin['symbol'] == ticker.upcase or coin['id'] == ticker.downcase or coin['name'].downcase == ticker.downcase
          return coin
        end
      end
    end
    def self.markets(ticker)
      markets_json = []
      markets_table = Nokogiri::HTML(open("https://coinmarketcap.com/currencies/#{self.find(ticker)['id']}/")).at_css("table[@id = 'markets-table']").at_css('tbody')
      markets_table.search('tr').each do |row|
        tds = row.search('td')
        item_json = {
            'rank' => tds[0].text,
            'name' => tds[1].text,
            'pair' => tds[2].text,
            '24h_volume' => tds[3].text,
            'price' => tds[3].text,
            'percent_volume' => tds[4].text
        }
        markets_json << item_json
        return markets_json.to_json
      end
    end
  end
  class Markets
    def self.na
    end
  end
  class News
    def self.search(keywords, secret_key)
      today = Date.today.strftime('%Y-%m-%d')
      yesterday = Date.today.prev_day.strftime('%Y-%m-%d')
      options = {query: {language: 'en',
                         sortBy: 'popularity',
                         apiKey: secret_key,
                         from: yesterday,
                         to: today,
                         q: keywords,
                         pageSize: '100'}}
      return HTTParty.get('https://newsapi.org/v2/everything?', options)['articles']
    end
  end
end
