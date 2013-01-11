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

  describe '#direct_link?' do
    subject { described_class.parse(args).direct_link? }

    context 'with no args' do
      let(:args) {[ '' ]}
      it { should eq(false) }
    end

    context 'with --direct' do
      let(:args) { %w(--direct) }
      it { should eq(true) }
    end

    context 'with -d' do
      let(:args) { %w(-d) }
      it { should eq(true) }
    end
  end

  describe '#action' do
    subject { described_class.parse(args).action }

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
      it { should eq(:share) }
    end
  end

  describe '#arguments' do
    subject { described_class.parse(args).arguments }

    context 'with no args' do
      let(:args) { [] }
      it { should be_empty }
    end

    context 'with args' do
      let(:args) { %w(one two) }
      it { should eq(%w(one two)) }
    end
  end

  # it "doesn't mutate array"
end
