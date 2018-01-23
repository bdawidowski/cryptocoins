require 'cryptocoins/version'
require 'httparty'
require 'open-uri'
require 'nokogiri'

module CryptoCoins
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
      markets_json = {
          ticker.downcase => []
      }
      begin
        markets_table = Nokogiri::HTML(open("https://coinmarketcap.com/currencies/#{self.find(ticker)['id']}/"))
        markets_table = markets_table.xpath("//table[@id = 'markets-table']/tbody")
        markets_table.search('tr').each do |row|
          tds = row.search('td')
          item_json = {
              'rank' => tds[0].text,
              'name' => tds[1].text,
              'pair' => tds[2].text,
              'link' => tds[2].xpath('./a/@href'),
              '24h_volume_usd' => tds[3].xpath('./span/@data-usd'),
              '24h_volume_btc' => tds[3].xpath('./span/@data-btc'),
              '24h_volume_native' => tds[3].xpath('./span/@data-native'),
              'price_usd' => tds[3].xpath('./span/@data-usd'),
              'price_btc' => tds[3].xpath('./span/@data-btc'),
              'price_native' => tds[3].xpath('./span/@data-native'),
              'percent_volume' => tds[4].xpath('./span/@data-format-value')
          }
          markets_json[ticker.downcase] << item_json
        end
        return markets_json.to_json
      rescue
        error = {
            'error' => "Invaild HTTP Request! **#{ticker.upcase}** Coin Not Supported!"
        }
        markets_table[ticker.downcase] = []
        markets_table[ticker.downcase] << error
      end
    end
  end
  class Markets
    def self.coins(market)
      coins_json = {
          market.downcase => []
      }
      begin
        coins_table = Nokogiri::HTML(open("https://coinmarketcap.com/exchanges/#{market.downcase}/"))
        coins_table = coins_table.xpath('//table/tbody')
        coins_table.search('tr').each_with_index do |row, i|
          if i > 0
            tds = row.search('td')
            item_json = {
                'rank' => tds[0].text,
                'name' => tds[1].text,
                'icon' => tds[1].xpath('./img/@src'),
                'link' => tds[2].xpath('./a/@href'),
                'pair' => tds[2].text,
                '24h_volume_usd' => tds[3].xpath('./span/@data-usd'),
                '24h_volume_btc' => tds[3].xpath('./span/@data-btc'),
                '24h_volume_native' => tds[3].xpath('./span/@data-native'),
                'price_usd' => tds[3].xpath('./span/@data-usd'),
                'price_btc' => tds[3].xpath('./span/@data-btc'),
                'price_native' => tds[3].xpath('./span/@data-native'),
                'percent_volume' => tds[4].text.gsub('%', '')
            }
          end
          coins_json[market.downcase] << item_json
        end
        return coins_table.to_json
      rescue
        error = {
            'error' => "Invaild HTTP Request! **#{market.upcase}** Exchange Not Supported!"
        }
        coins_table[market.downcase] = []
        coins_table[market.downcase] << error
        return coins_table.to_json
      end
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
    def self.bitcoin(secret_key)
      return self.search('+bitcoin', secret_key)
    end
  end
end
