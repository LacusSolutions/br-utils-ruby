# frozen_string_literal: true

require 'spec_helper'
require 'commit_lint'

RSpec.describe CommitLint do
  describe '.lint' do
    subject(:errors) { described_class.lint(message) }

    context 'with a valid header' do
      let(:message) { 'feat: add cnpj masking helper' }

      it { is_expected.to be_empty }
    end

    context 'with a valid scoped header' do
      let(:message) { 'fix(cnpj-dv): handle blank input' }

      it { is_expected.to be_empty }
    end

    context 'with a breaking-change marker' do
      let(:message) { 'refactor(br-utils)!: drop deprecated entrypoint' }

      it { is_expected.to be_empty }
    end

    context 'with a scope whose name differs from the gem name' do
      let(:message) { 'feat(utils): add lacus helper' }

      it { is_expected.to be_empty }
    end

    context 'when the type is unknown' do
      let(:message) { 'foo: do something' }

      it 'reports the invalid type' do
        expect(errors).to include(a_string_matching(/type must be one of/))
      end
    end

    context 'when the type is upper-case' do
      let(:message) { 'Feat: add helper' }

      it 'reports a lower-case violation' do
        expect(errors).to include(a_string_matching(/type must be lower-case/))
      end
    end

    context 'when the scope is not one of the allowed package scopes' do
      let(:message) { 'fix(unknown): tweak' }

      it 'reports the disallowed scope' do
        expect(errors).to include(a_string_matching(/is not allowed/))
      end
    end

    context 'when the scope uses a gem name instead of the allowed alias' do
      let(:message) { 'fix(lacus-utils): tweak' }

      it 'reports the disallowed scope' do
        expect(errors).to include(a_string_matching(/is not allowed/))
      end
    end

    context 'when the header does not follow the pattern' do
      let(:message) { 'just a plain message' }

      it 'reports a format violation' do
        expect(errors).to include(a_string_matching(/must match/))
      end
    end

    context 'when the subject ends with a period' do
      let(:message) { 'docs: update the readme.' }

      it 'reports the trailing period' do
        expect(errors).to include(a_string_matching(/must not end with a period/))
      end
    end

    context 'when the subject starts with an upper-case letter' do
      let(:message) { 'docs: Update the readme' }

      it 'reports the sentence-case subject' do
        expect(errors).to include(a_string_matching(/must not start with an upper-case letter/))
      end
    end

    context 'when the header is too long' do
      let(:message) { "feat: #{'a' * 120}" }

      it 'reports the length violation' do
        expect(errors).to include(a_string_matching(/must not exceed/))
      end
    end

    context 'when the body is missing its leading blank line' do
      let(:message) { "feat: add helper\nno blank line above" }

      it 'reports the missing blank line' do
        expect(errors).to include(a_string_matching(/blank line/))
      end
    end

    context 'when the commit is a merge commit' do
      let(:message) { 'Merge branch main into feature' }

      it { is_expected.to be_empty }
    end

    context 'when the commit is a revert commit' do
      let(:message) { 'Revert "feat: add helper"' }

      it { is_expected.to be_empty }
    end
  end

  describe '.allowed_scopes' do
    subject(:scopes) { described_class.allowed_scopes }

    it 'is the fixed per-package scope list' do
      expect(scopes).to contain_exactly(
        'utils', 'cnpj-dv', 'cnpj-fmt', 'cnpj-gen', 'cnpj-val', 'cnpj-utils',
        'cpf-dv', 'cpf-fmt', 'cpf-gen', 'cpf-val', 'cpf-utils', 'br-utils'
      )
    end
  end
end
