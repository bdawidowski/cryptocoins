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
              'link' => tds[2].xpath('./a/@href').first.value,
              '24h_volume_usd' => tds[3].xpath('./span/@data-usd').first.value,
              '24h_volume_btc' => tds[3].xpath('./span/@data-btc').first.value,
              '24h_volume_native' => tds[3].xpath('./span/@data-native').first.value,
              'price_usd' => tds[4].xpath('./span/@data-usd').first.value,
              'price_btc' => tds[4].xpath('./span/@data-btc').first.value,
              'price_native' => tds[4].xpath('./span/@data-native').first.value,
              'percent_volume' => tds[5].xpath('./span/@data-format-value').first.value
          }
          markets_json[ticker.downcase] << item_json
        end
        return markets_json
      rescue
        error = {
            'error' => "Invaild HTTP Request! **#{ticker.upcase}** Coin Not Supported!"
        }
        markets_json[ticker.downcase] = []
        markets_json[ticker.downcase] << error
        return markets_json
      end
    end
  end
  class Market
    def self.coins(market)
      coins_json = {
          market.downcase => []
      }
      begin
        coins_table = Nokogiri::HTML(open("https://coinmarketcap.com/exchanges/#{market.downcase}/"))
        coins_table = coins_table.xpath("//div[@class = 'table-responsive']/table")
        coins_table.search('tr').each_with_index do |row, i|
          if i > 0
            tds = row.search('td')
            item_json = {
                'rank' => tds[0].text,
                'name' => tds[1].text,
                'icon' => tds[1].xpath('./img/@src').first.value,
                'link' => tds[2].xpath('./a/@href').first.value,
                'pair' => tds[2].text,
                '24h_volume_usd' => tds[3].xpath('./span/@data-usd').first.value,
                '24h_volume_btc' => tds[3].xpath('./span/@data-btc').first.value,
                '24h_volume_native' => tds[3].xpath('./span/@data-native').first.value,
                'price_usd' => tds[4].xpath('./span/@data-usd').first.value,
                'price_btc' => tds[4].xpath('./span/@data-btc').first.value,
                'price_native' => tds[4].xpath('./span/@data-native').first.value,
                'percent_volume' => tds[5].text.gsub('[\s\r\n%]+', '')
            }
          end
          coins_json[market.downcase] << item_json
        end
        return coins_json
      rescue
        error = {
            'error' => "Invaild HTTP Request! **#{market.upcase}** Exchange Not Supported!"
        }
        coins_json[market.downcase] = []
        coins_json[market.downcase] << error
        return coins_json
      end
    end
  end
  class News
    def self.search(secret_key, options = {})
      request = {query: {language: 'en',
                         sortBy: 'popularity',
                         apiKey: secret_key,
                         from: Date.today.prev_day.strftime('%Y-%m-%d'),
                         to: Date.today.strftime('%Y-%m-%d'),
                         q: '+bitcoin',
                         pageSize: '100'}}
      options.each do |key, value|
        request[:query][key] = value if request[:query][key]
      end
      request[:query].merge!(sources: options[:sources]) if options[:sources]
      return HTTParty.get('https://newsapi.org/v2/everything?', request)['articles']
    end
  end
end
