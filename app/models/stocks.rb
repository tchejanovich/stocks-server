module Stocks
    def stock_values(ticker, from, to)
        info_status_code, info_body = stock_info(ticker, from, to)
        return error_response if info_status_code != 200
        
        parsed_body = JSON.parse(info_body)
        return no_content_response if parsed_body['resultsCount'] == 0
        [200, calculate_values(parsed_body['results'])]
    end

    private

    def no_content_response
        [204]
    end

    def error_response
        [500, { error: 'Unexpected error' }]
    end
    
    def stock_info(ticker, from, to)
        begin
            url = "https://api.polygon.io/v2/aggs/ticker/#{ticker}/range/1/day/#{from}/#{to}?apiKey=taIMgMrmnZ8SUZmdpq9_7ANRDxw3IPIx"
            response = HTTParty.get(url)
            [response.code, response.body]
        rescue StandardError => e
            [500]
        end
    end

    def calculate_values(daily_results)
        min_price, max_price, price_accumulator = nil, nil, 0
        min_volume, max_volume, volume_accumulator = nil, nil, 0
        
        daily_results.each do |result|
            lowest_price = result['l']
            highest_price = result['h']
            volume = result['v']

            min_price = lowest_price if min_price.blank? || lowest_price < min_price
            max_price = highest_price if max_price.blank? || highest_price > max_price
            price_accumulator += lowest_price + highest_price

            min_volume = volume if min_volume.blank? || volume < min_volume
            max_volume = volume if max_volume.blank? || volume > max_volume
            volume_accumulator += volume 
        end

        {
            min_price: min_price,
            max_price: max_price,
            average_price: price_accumulator / (2 * daily_results.size), # We double the results size since for each day both the lowest and highest price were added into the array
            min_volume: min_volume,
            max_volume: max_volume,
            average_volume: volume_accumulator / daily_results.size
        }
    end
end
