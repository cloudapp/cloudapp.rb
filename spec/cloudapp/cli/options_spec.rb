require 'helper'
require 'cloudapp/cli/options'

describe CloudApp::CLI::Options do
  describe '#copy_link?' do
    subject { described_class.parse(args).copy_link? }

    context 'with no args' do
      let(:args) {[ '' ]}
      it { should eq(true) }
    end

    context 'with --no-copy' do
      let(:args) { %w(--no-copy) }
      it { should eq(false) }
    end

    context 'with --copy' do
      let(:args) { %w(--copy) }
      it { should eq(true) }
    end
  end

  describe '#link_type' do
    subject { described_class.parse(args).link_type }

    context 'with no args' do
      let(:args) {[ '' ]}
      it { should eq(:canonical) }
    end

    context 'with --direct' do
      let(:args) { %w(--direct) }
      it { should eq(:embed) }
    end

    context 'with -d' do
      let(:args) { %w(-d) }
      it { should eq(:embed) }
    end

    context 'with --direct when bookmarking' do
      let(:args) { %w(bookmark --direct) }
      it { should eq(:canonical) }
    end
  end

  describe '#action' do
    subject { described_class.parse(args).action }

    context 'with bookmark' do
      let(:args) { %w(bookmark) }
      it { should eq(:bookmark) }
    end

    context 'with upload' do
      let(:args) { %w(upload) }
      it { should eq(:upload) }
    end

    context 'with help' do
      let(:args) { %w(help) }
      it { should eq(:help) }
    end

    context 'with --help' do
      let(:args) { %w(--help) }
      it { should eq(:help) }
    end

    context 'with -h' do
      let(:args) { %w(-h) }
      it { should eq(:help) }
    end

    context 'with --version' do
      let(:args) { %w(--version) }
      it { should eq(:version) }
    end

    context 'with no args' do
      let(:args) {[ '' ]}
      it { should eq(:invalid) }
    end

    context 'with an invalid command' do
      let(:args) {[ '' ]}
      it { should eq(:invalid) }
    end
  end

  describe '#arguments' do
    subject { described_class.parse(args).arguments }

    context 'with no args' do
      let(:args) {[ '' ]}
      it { should be_empty }
    end

    context 'with no args when bookmarking' do
      let(:args) { %w(bookmark) }
      it { should be_empty }
    end

    context 'with args when bookmarking' do
      let(:args) { %w(bookmark one two) }
      it { should eq(%w(one two)) }
    end
  end

  # it "doesn't mutate array"
end
