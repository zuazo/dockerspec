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

describe Dockerspec::Builder::ImageGC do
  subject { described_class.instance }
  before do
    subject.instance_variable_set(:@images, [])
    allow(ObjectSpace).to receive(:define_finalizer)
  end
  after { subject.finalize } # make sure there are no reamining images

  context '.new' do
    it 'defines a finalizer' do
      expect(ObjectSpace).to receive(:define_finalizer)
      Dockerspec::Builder::ImageGC.send(:new)
    end
  end

  context '#add' do
    let(:image1) { 'image1' }
    before { allow(Docker::Image).to receive(:remove) }

    it 'adds an image' do
      subject.add(image1)
    end
  end

  context '#finalize' do
    let(:image1) { 'image1' }
    let(:image2) { 'image2' }
    before do
      subject.add(image1)
      subject.add(image2)
    end

    it 'removes the images' do
      expect(Docker::Image).to receive(:remove).once.with(image1, force: true)
      expect(Docker::Image).to receive(:remove).once.with(image2, force: true)
      subject.finalize
    end
  end
end
