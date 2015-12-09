# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Dockerspec::Builder do
  let(:file) { double('StringIO') }
  let(:image_id) { '198a73cfd686' }
  let(:image) { double('Docker::Image') }
  let(:image_gc) { double('Dockerspec::Builder::ImageGC') }
  let(:tmpdir) { '/tmp/d20151208-1396-xutmns' }
  before do
    allow(Docker::Image).to receive(:build_from_dir).and_return(image)
    allow(Docker::Image).to receive(:build).and_return(image)
    allow(Docker::Image).to receive(:get).and_return(image)
    allow(Docker::Image).to receive(:create)
    allow(image).to receive(:id).and_return(image_id)
    allow(Dockerspec::Builder::ImageGC).to receive(:instance)
      .and_return(image_gc)
    allow(image_gc).to receive(:add)
    allow(IO).to receive(:read).and_call_original
    allow(Dir).to receive(:mktmpdir).and_yield(tmpdir)
    allow(FileUtils).to receive(:cp_r).and_call_original
    allow(FileUtils).to receive(:cp_r).with(anything, tmpdir)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with("#{tmpdir}/Dockerfile", 'w')
      .and_yield(file)
    allow(file).to receive(:write)
  end

  context '.new' do
    it 'creates an image' do
      described_class.new
    end
  end

  context '#id' do
    it 'returns the image id' do
      subject.build
      expect(subject.id).to eq image_id
    end
  end

  context '#build' do
    it 'builds an image' do
      builder = described_class.new
      builder.build
    end

    context 'passing a string' do
      let(:path) { '/tmp' }
      subject { described_class.new(path) }
      before do
        allow(Docker::Image).to receive(:build_from_dir).with(path).once
          .and_return(image)
      end

      it 'builds an image from a directory' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from path:/)
      end
    end

    context 'with a string option' do
      let(:string) { 'FROM nginx' }
      subject { described_class.new(string: string) }
      before do
        allow(Docker::Image).to receive(:build).with(string).once
          .and_return(image)
      end

      it 'builds an image from a string' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from string:/)
      end

      it 'trims description' do
        subject = described_class.new(string: "#{string}\n#{string}")
        expect(subject.to_s).to match(/Docker Build from string: .*\.\.\./m)
      end

      context 'when calling the build block' do
        let(:chunk) { { 'stream' => "Step 1 : FROM alpine:3.2\n" } }
        let(:logger) { double('Dockerspec::Builder::Logger') }
        before do
          expect(Docker::Image).to receive(:build_from_dir).with(tmpdir).once
            .and_yield(chunk)
            .and_return(image)
          expect(file).to receive(:write).once.with(string)
          expect(logger).to receive(:print_chunk).at_least(1)
          expect(Dockerspec::Builder::Logger).to receive(:instance)
            .and_return(logger)
        end

        it 'creates the logger' do
          subject.build
        end
      end
    end

    context 'passing a file to the path option' do
      let(:file) { '/tmp/file' }
      let(:content) { 'FROM nginx' }
      subject { described_class.new(path: file) }
      before do
        allow(IO).to receive(:read).with(file).and_return(content)
        allow(Docker::Image).to receive(:build_from_dir).with(tmpdir).once
          .and_return(image)
      end

      it 'builds an image from a file' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from path:/)
      end
    end

    context 'with a template option' do
      let(:file) { '/tmp/file.erb' }
      let(:content) { '<%= "FROM nginx" %>' }
      subject { described_class.new(template: file) }
      before do
        allow(IO).to receive(:read).with(file).and_return(content)
        allow(Docker::Image).to receive(:build).with('FROM nginx').once
          .and_return(image)
      end

      it 'builds an image from a Erubis template' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from template:/)
      end
    end

    context 'passing a directory to the path option' do
      let(:path) { '/tmp' }
      subject { described_class.new(path: path) }
      before do
        allow(Docker::Image).to receive(:build_from_dir).with(path).once
          .and_return(image)
      end

      it 'builds an image from a directory' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from path:/)
      end

      context 'when calling the build block' do
        let(:chunk) { { 'stream' => "Step 1 : FROM alpine:3.2\n" } }
        let(:logger) { double('Dockerspec::Builder::Logger') }
        before do
          expect(Docker::Image).to receive(:build_from_dir).with(path).once
            .and_yield(chunk)
            .and_return(image)
          expect(logger).to receive(:print_chunk).at_least(1)
          expect(Dockerspec::Builder::Logger).to receive(:instance)
            .and_return(logger)
        end

        it 'creates the logger' do
          subject.build
        end
      end
    end

    context 'passing a Dockerfile to the path option' do
      let(:dir) { '/tmp' }
      let(:file) { "#{dir}/Dockerfile" }
      subject { described_class.new(path: file) }
      before do
        allow(Docker::Image).to receive(:build_from_dir).with(dir).once
          .and_return(image)
      end

      it 'builds an image from a directory' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from path:/)
      end

      context 'when calling the build block' do
        let(:chunk) { { 'stream' => "Step 1 : FROM alpine:3.2\n" } }
        let(:logger) { double('Dockerspec::Builder::Logger') }
        before do
          expect(Docker::Image).to receive(:build_from_dir).with(dir).once
            .and_yield(chunk)
            .and_return(image)
          expect(logger).to receive(:print_chunk).at_least(1)
          expect(Dockerspec::Builder::Logger).to receive(:instance)
            .and_return(logger)
        end

        it 'creates the logger' do
          subject.build
        end
      end
    end

    context 'with an image_id option' do
      subject { described_class.new(id: image_id) }
      before do
        allow(Docker::Image).to receive(:get).with(image_id).once
          .and_return(image)
      end

      it 'builds an image from an image ID' do
        expect(subject.build).to be_a Dockerspec::Builder
      end

      it 'returns the correct image ID' do
        subject.build
        expect(subject.id).to eq image_id
      end

      it 'returns the correct description' do
        expect(subject.to_s).to match(/^Docker Build from id:/)
      end

      context 'when the image is not found' do
        before do
          expect(Docker::Image).to receive(:get)
            .with(image_id).and_raise Docker::Error::NotFoundError
        end
        it 'pulls the image' do
          expect(Docker::Image)
            .to receive(:create).once.with('fromImage' => image_id)
          subject.build
        end
      end
    end

    context 'with tag option' do
      let(:repo) { 'reponame' }
      subject { described_class.new(tag: repo) }

      it 'creates an image tag' do
        expect(image)
          .to receive(:tag).with(repo: repo, tag: nil, force: true).once
        subject.build
      end
    end

    context 'with tag option including the repo and a tag' do
      let(:repo) { 'reponame' }
      let(:tag) { 'tagname' }
      subject { described_class.new(tag: "#{repo}:#{tag}") }

      it 'creates an image tag' do
        expect(image)
          .to receive(:tag).with(repo: repo, tag: tag, force: true).once
        subject.build
      end
    end

    context 'with rm option' do
      subject { described_class.new(rm: true) }

      it 'uses the image GC' do
        expect(Dockerspec::Builder::ImageGC).to receive(:instance).once
          .and_return(image_gc)
        subject.build
      end
    end

    context 'without rm option' do
      subject { described_class.new(rm: false) }

      it 'uses the image GC' do
        expect(Dockerspec::Builder::ImageGC).to_not receive(:instance)
        subject.build
      end
    end
  end # context #build

  context '#to_s' do
    it 'returns a description' do
      expect(subject.to_s).to match(/^Docker Build from/)
    end
  end
end
