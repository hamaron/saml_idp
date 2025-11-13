module SamlIdp
  class NameIdFormatter
    attr_accessor :list
    def initialize(list)
      self.list = (list || {})
    end

    def all
      if split?
        one_one.map { |key_val| build("1.1", key_val)[:name] } +
        two_zero.map { |key_val| build("2.0", key_val)[:name] }
      else
        list.map { |key_val| build("2.0", key_val)[:name] }
      end
    end

    def chosen
      if split?
        version, choose = "1.1", one_one.first
        version, choose = "2.0", two_zero.first unless choose
        version, choose = "2.0", "persistent" unless choose
        build(version, choose)
      else
        choose = list.first || "persistent"
        build("2.0", choose)
      end
    end

    def build(version, key_val)
      key_val = Array(key_val)
      raw_name = key_val.first

      name = literal_urn?(raw_name) ? raw_name.to_s : build_urn(version, raw_name)
      getter_key = key_val.length > 1 ? key_val.last : default_getter_value(raw_name)

      {
        name: name,
        getter: build_getter(getter_key)
      }
    end
    private :build

    def build_urn(version, key_val)
      name = key_val.to_s.underscore
      "urn:oasis:names:tc:SAML:#{version}:nameid-format:#{name.camelize(:lower)}"
    end
    private :build_urn

    def default_getter_value(name)
      if literal_urn?(name)
        name.to_s.split(':nameid-format:').last.to_s.underscore
      else
        name.to_s.underscore
      end
    end
    private :default_getter_value

    def literal_urn?(value)
      value.respond_to?(:to_s) && value.to_s.include?(':nameid-format:')
    end
    private :literal_urn?

    def build_getter(getter_val)
      if getter_val.respond_to?(:call)
        getter_val
      else
        ->(p) { p.public_send getter_val.to_s }
      end
    end
    private :build_getter

    def split?
      list.is_a?(Hash) && (list.key?("2.0") || list.key?("1.1"))
    end
    private :split?

    def one_one
      list["1.1"] || {}
    rescue TypeError
      {}
    end
    private :one_one

    def two_zero
      list["2.0"] || {}
    rescue TypeError
      {}
    end
    private :two_zero
  end
end
