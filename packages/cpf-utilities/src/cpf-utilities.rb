# frozen_string_literal: true

require 'cpf-fmt'
require 'cpf-gen'
require 'cpf-val'
require_relative 'cpf-utilities/version'

# Entry point for the +cpf-utilities+ gem.
#
# Loads sibling packages (+cpf-fmt+, +cpf-gen+, +cpf-val+) and defines the
# {CpfUtils} façade class. +version.rb+ defines a placeholder module so the
# gemspec can read {CpfUtils::VERSION}; this file promotes it to the class
# consumers instantiate.
#
# Two-tier access after +require 'cpf-utilities'+:
#
# - *Main shortcuts* at the façade root: {CpfUtils::CpfFormatter},
#   {CpfUtils::CpfGenerator}, {CpfUtils::CpfValidator}.
# - *Package nests* for the full sibling surface (Options, helpers, errors,
#   types): {CpfUtils::CpfFmt}, {CpfUtils::CpfGen}, {CpfUtils::CpfVal}
#   (same objects as +::CpfFmt+, +::CpfGen+, +::CpfVal+).
# - Root siblings (+CpfFmt+, +CpfGen+, +CpfVal+) remain supported unchanged.
unless CpfUtils.is_a?(Class)
  version = CpfUtils::VERSION
  Object.send(:remove_const, :CpfUtils)
  CpfUtils = Class.new
  CpfUtils.const_set(:VERSION, version)
end

require_relative 'cpf-utilities/errors'
require_relative 'cpf-utilities/cpf_utils'
require_relative 'cpf-utilities/cpf_fmt'
require_relative 'cpf-utilities/cpf_gen'
require_relative 'cpf-utilities/cpf_val'
