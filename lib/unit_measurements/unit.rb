# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "set"

module UnitMeasurements
  class Unit
    attr_reader :name, :value, :aliases, :system, :unit_group

    def initialize(name, value:, aliases:, system:, unit_group: nil)
      @name = name.to_s.freeze
      @value = value
      @aliases = Set.new(aliases.sort.map(&:to_s).map(&:freeze)).freeze
      @system = system
      @unit_group = unit_group
    end

    def with(name: nil, value: nil, aliases: nil, system: nil, unit_group: nil)
      self.class.new(
        (name || self.name),
        value: (value || self.value),
        aliases: (aliases || self.aliases),
        system: (system || self.system),
        unit_group: (unit_group || self.unit_group)
      )
    end

    def names
      (aliases + [name]).sort.freeze
    end

    def to_s
      name
    end

    def inspect
      aliases = "(#{@aliases.join(", ")})" if @aliases.any?
      "#<#{self.class.name}: #{name} #{aliases}>"
    end

    def conversion_factor
      return value if value.is_a?(Numeric)

      measurement_value, measurement_unit = parse_value(value)
      conversion_factor = unit_group.unit_for!(measurement_unit).conversion_factor
      conversion_factor * measurement_value
    end

    private

    SI_PREFIXES = [
      ["q",  %w(quecto),    1e-30],
      ["r",  %w(ronto),     1e-27],
      ["y",  %w(yocto),     1e-24],
      ["z",  %w(zepto),     1e-21],
      ["a",  %w(atto),      1e-18],
      ["f",  %w(femto),     1e-15],
      ["p",  %w(pico),      1e-12],
      ["n",  %w(nano),      1e-9],
      ["μ",  %w(micro),     1e-6],
      ["m",  %w(milli),     1e-3],
      ["c",  %w(centi),     1e-2],
      ["d",  %w(deci),      1e-1],
      ["da", %w(deca deka), 1e+1],
      ["h",  %w(hecto),     1e+2],
      ["k",  %w(kilo),      1e+3],
      ["M",  %w(mega),      1e+6],
      ["G",  %w(giga),      1e+9],
      ["T",  %w(tera),      1e+12],
      ["P",  %w(peta),      1e+15],
      ["E",  %w(exa),       1e+18],
      ["Z",  %w(zetta),     1e+21],
      ["Y",  %w(yotta),     1e+24],
      ["R",  %w(ronna),     1e+27],
      ["Q",  %w(quetta),    1e+30]
    ].map(&:freeze).freeze

    def parse_value(tokens)
      case tokens
      when String
        tokens = Parser.parse(value)
      when Array
        raise BaseError, "Cannot parse [number, unit] formatted tokens from #{tokens}." unless tokens.size == 2
      else
        raise BaseError, "Value of the unit must be defined as string or array, but received #{tokens}"
      end
      [tokens[0].to_r, tokens[1].freeze]
    end
  end
end
