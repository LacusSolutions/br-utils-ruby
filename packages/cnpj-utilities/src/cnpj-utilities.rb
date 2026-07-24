# frozen_string_literal: true

require 'cnpj-fmt'
require 'cnpj-gen'
require 'cnpj-val'
require_relative 'cnpj-utilities/version'

# Entry point for the +cnpj-utilities+ gem.
#
# Loads sibling packages (+cnpj-fmt+, +cnpj-gen+, +cnpj-val+) and defines the
# {CnpjUtils} façade class. +version.rb+ defines a placeholder module so the
# gemspec can read {CnpjUtils::VERSION}; this file promotes it to the class
# consumers instantiate.
#
# Two-tier access after +require 'cnpj-utilities'+:
#
# - *Main shortcuts* at the façade root: {CnpjUtils::CnpjFormatter},
#   {CnpjUtils::CnpjGenerator}, {CnpjUtils::CnpjValidator}.
# - *Package nests* for the full sibling surface (Options, helpers, errors,
#   types): {CnpjUtils::CnpjFmt}, {CnpjUtils::CnpjGen}, {CnpjUtils::CnpjVal}
#   (same objects as +::CnpjFmt+, +::CnpjGen+, +::CnpjVal+).
# - Root siblings (+CnpjFmt+, +CnpjGen+, +CnpjVal+) remain supported unchanged.
unless CnpjUtils.is_a?(Class)
  version = CnpjUtils::VERSION
  Object.send(:remove_const, :CnpjUtils)
  CnpjUtils = Class.new
  CnpjUtils.const_set(:VERSION, version)
end

require_relative 'cnpj-utilities/errors'
require_relative 'cnpj-utilities/cnpj_utils'
require_relative 'cnpj-utilities/cnpj_fmt'
require_relative 'cnpj-utilities/cnpj_gen'
require_relative 'cnpj-utilities/cnpj_val'
