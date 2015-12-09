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

describe Dockerspec::Builder::Matchers do
  path = File.join(File.dirname(__FILE__), '..', '..', 'data')

  context docker_build(path: path) do
    context ':string predicate type' do
      context 'failure message' do
        let(:test) { expect(subject).to have_maintainer 'who?' }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `MAINTAINER`/)
        end

        it 'contains the expected value' do
          expect { test }.to raise_error(/to match `"who\?"`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `John Doe/)
        end
      end

      context 'failure message when negated' do
        let(:test) { expect(subject).to_not have_maintainer(/John/) }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `MAINTAINER`/)
        end

        it 'contains the "not" expected value' do
          expect { test }.to raise_error(%r{not to match `/John/`})
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `John Doe/)
        end
      end
    end # context :string predicate type

    context ':json predicate type' do
      context 'failure message' do
        let(:test) { expect(subject).to have_cmd %w(badcmd) }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `CMD`/)
        end

        it 'contains the expected value' do
          expect { test }.to raise_error(/to be `\["badcmd"\]`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `\["2", "2000"\]`/)
        end
      end

      context 'failure message when negated' do
        let(:test) { expect(subject).to_not have_cmd %w(2 2000) }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `CMD`/)
        end

        it 'contains the "not" expected value' do
          expect { test }.to raise_error(/not to be `\["2", "2000"\]`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `\["2", "2000"\]`/)
        end
      end
    end # context :json predicate type

    context ':array predicate type' do
      context 'failure message' do
        let(:test) { expect(subject).to have_expose '90' }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `EXPOSE`/)
        end

        it 'contains the expected value' do
          expect { test }.to raise_error(/to include `"90"`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `\["80"\]`/)
        end
      end

      context 'failure message when negated' do
        let(:test) { expect(subject).to_not have_expose '80' }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `EXPOSE`/)
        end

        it 'contains the "not" expected value' do
          expect { test }.to raise_error(/not to include `"80"`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `\["80"\]`/)
        end
      end
    end # context :array predicate type

    context ':hash predicate type' do
      context 'failure message' do
        let(:test) { expect(subject).to have_label('badlabel' => 'badval') }

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `LABEL`/)
        end

        it 'contains the expected value' do
          expect { test }
            .to raise_error(/to contain `{"badlabel"=>"badval"}`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `{"description"=>"My /)
        end
      end

      context 'failure message when negated' do
        let(:test) do
          expect(subject).to_not have_label('description' => 'My Container')
        end

        it 'contains the matcher name' do
          expect { test }.to raise_error(/expected `LABEL`/)
        end

        it 'contains the "not" expected value' do
          expect { test }
            .to raise_error(/not to contain `{"description"=>"My Container"}`/)
        end

        it 'contains the actual value' do
          expect { test }.to raise_error(/got `{"description"=>"My /)
        end
      end
    end # context :hash predicate type
  end # docker build
end
