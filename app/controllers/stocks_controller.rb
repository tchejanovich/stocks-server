class StocksController < ApplicationController
    include Stocks

    def show
        valid, error = validate_dates(params[:from], params[:to])
        return render status: :bad_request, json: { error: error} unless valid

        status_code, body = stock_values(params[:id], params[:from], params[:to])
        render status: status_code, json: body
    end

    private 

    def validate_dates(from_str, to_str)
        from_date = parse_date(from_str)
        return [false, 'from date is invalid'] if from_date.blank?
        to_date = parse_date(to_str)
        return [false, 'to date is invalid'] if to_date.blank?
        return [false, 'to should be greater than from'] if from_date > to_date
        true
    end

    def parse_date(date_str)
        return nil if !!!date_str.match(/\A\d{4}-\d{2}-\d{2}\z/) 
        return Date.parse(date_str) rescue nil
    end
end
