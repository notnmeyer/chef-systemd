#
# Cookbook Name:: systemd
# Spec:: default
#
# Copyright 2015 The Authors
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

require 'spec_helper'

describe 'systemd::udevd' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'manages udev, but not by default' do
      expect(chef_run).to_not create_file('/etc/udev/udev.conf')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'On deb-family platform when systemd-udevd options are given' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['systemd']['udev']['options']['children-max'] = 10
      end.converge(described_recipe)
    end

    it 'uses the appropriate systemd-udevd path' do
      expect(chef_run).to create_systemd_service('local-udevd-options').with(
        drop_in: true,
        override: 'systemd-udevd',
        overrides: %w( ExecStart ),
        exec_start: '/lib/systemd/systemd-udevd --children-max=10'
      )
    end
  end

  context 'On non-deb-family platform when systemd-udevd options are given' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0') do |node|
        node.set['systemd']['udev']['options']['children-max'] = 10
      end.converge(described_recipe)
    end

    it' uses the appropriate systemd-udevd path' do
      expect(chef_run).to create_systemd_service('local-udevd-options').with(
        drop_in: true,
        override: 'systemd-udevd',
        overrides: %w( ExecStart ),
        exec_start: '/usr/lib/systemd/systemd-udevd --children-max=10'
      )
    end
  end
end
