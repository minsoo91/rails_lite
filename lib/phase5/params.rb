require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
        @params = {}
        unless req.query_string.nil?
            parse_www_encoded_form(req.query_string)
        end
        unless req.body.nil?
            parse_www_encoded_form(req.body)
        end
        unless route_params.empty?
            @params = route_params
        end
    end

    def [](key)
        @params[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
        key_value_sets = URI::decode_www_form(www_encoded_form)
        key_value_sets.each do |key_value_set|
            key_value_set[0] = parse_key(key_value_set[0])
        end
        key_value_sets.each do |key_value_set|
            keys = key_value_set[0]
            @current = @params
            keys[0..-2].each do |key|
                @current[key] ||= {}
                @current = @current[key]
            end
            @current[keys.last] = key_value_set[1]
        end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
        key.split(/\]\[|\[|\]/)
    end
  end
end
