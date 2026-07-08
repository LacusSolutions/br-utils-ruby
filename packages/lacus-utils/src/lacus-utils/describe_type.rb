# frozen_string_literal: true

require 'set'

module LacusUtils
  # Describes the type of a value for error messages. Returns a short
  # human-readable string describing the runtime type of the value. Pure,
  # deterministic, and never raises.
  #
  # @param value [Object] any value to describe
  # @return [String] a human-readable type label
  #
  # @example
  #   LacusUtils.describe_type(nil)              # => 'nil'
  #   LacusUtils.describe_type('hello')          # => 'string'
  #   LacusUtils.describe_type(true)             # => 'boolean'
  #   LacusUtils.describe_type(42)               # => 'integer number'
  #   LacusUtils.describe_type(3.14)             # => 'float number'
  #   LacusUtils.describe_type(Float::NAN)       # => 'NaN'
  #   LacusUtils.describe_type(Float::INFINITY)  # => 'Infinity'
  #   LacusUtils.describe_type([])               # => 'Array (empty)'
  #   LacusUtils.describe_type([1, 2, 3])        # => 'number[]'
  #   LacusUtils.describe_type([1, 'a', 2])      # => '(number | string)[]'
  #   LacusUtils.describe_type({})               # => 'hash'
  def self.describe_type(value)
    return describe_type_array(value) if value.is_a?(Array)

    describe_type_scalar(value)
  end

  def self.describe_type_scalar(value)
    return 'nil' if value.nil?
    return 'boolean' if [true, false].include?(value)

    describe_type_numeric(value) || describe_type_named(value)
  end
  private_class_method :describe_type_scalar

  def self.describe_type_numeric(value)
    case value
    when Integer then 'integer number'
    when Float then describe_type_float(value, 'float number')
    when Complex then 'complex number'
    when Rational then 'rational number'
    end
  end
  private_class_method :describe_type_numeric

  def self.describe_type_named(value)
    case value
    when String then 'string'
    when Symbol then 'symbol'
    when Hash then 'hash'
    when Set then 'set'
    else describe_type_callable(value)
    end
  end
  private_class_method :describe_type_named

  def self.describe_type_callable(value)
    case value
    when Proc, Method then 'function'
    when Module then 'class'
    else 'object'
    end
  end
  private_class_method :describe_type_callable

  def self.describe_type_float(value, finite_label)
    return 'NaN' if value.nan?
    return 'Infinity' if value.infinite?

    finite_label
  end
  private_class_method :describe_type_float

  def self.describe_type_array(array)
    return 'Array (empty)' if array.empty?

    types = array.map { |item| describe_type_item(item) }.uniq

    return "#{types.first}[]" if types.length == 1

    "(#{types.join(' | ')})[]"
  end
  private_class_method :describe_type_array

  def self.describe_type_item(item)
    case item
    when nil then 'nil'
    when true, false then 'boolean'
    when Integer then 'number'
    when Float then describe_type_float(item, 'number')
    when String then 'string'
    else describe_type(item)
    end
  end
  private_class_method :describe_type_item
end
