class StocksController < ApplicationController
    include Stocks

    def show
        begin
            error = validate?
            return render status: :bad_request, json: build_error_object(error) if error.present?

            error, status_code, body = stock_values(params[:id], params[:from], params[:to])
            return render unexpected_error_response if error
            render status: status_code, json: body
        rescue StandardError => e
            render unexpected_error_response
        end
    end

    private 

    def valid_dates?
        from_date = parse_date(params[:from])
        return "'from' date is invalid" if from_date.blank?
        to_date = parse_date(params[:to])
        return "'to' date is invalid" if to_date.blank?
        return "'to' should be greater than 'from'" if from_date > to_date
        return "'to' cannot be greater than today" if Date.today < to_date
        nil
    end

    def parse_date(date_str)
        return nil if !!!date_str.match(/\A\d{4}-\d{2}-\d{2}\z/) 
        return Date.parse(date_str) rescue nil
    end

    def valid_params?
        missing_params = []
        missing_params.push('ticker') if params[:id].blank?
        missing_params.push('from') if params[:from].blank?
        missing_params.push('to') if params[:to].blank?
        missing_params.any? ? build_missing_params_error_message(missing_params) : nil
    end

    def build_error_object(error_message)
        { error: error_message} 
    end

    def build_missing_params_error_message(missing_params)
        "Missing params: #{missing_params.join(',')}"
    end

    def validate?
        error = valid_params?
        return error if error.present?
        error = valid_dates?
        return error if error.present?
        nil
    end

    def unexpected_error_response
        { status: 500, json: build_error_object('Unexpected error') }
    end
end
