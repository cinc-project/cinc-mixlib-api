# frozen_string_literal: true
#
# Author:: Lance Albertson (<lance@osuosl.org>)
# Copyright:: Copyright 2019, Cinc Project
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

require 'json'
require 'fileutils'

BASE_PATH = ENV.fetch('CINC_FILES', 'downloads/files')
API_PATH = ENV.fetch('CINC_API', 'api')
PRODUCT = ENV.fetch('CINC_PRODUCT', 'cinc')
CHANNELS = %w[stable current unstable].freeze

# Hashes for storing information from the metadata.json files
versions = {}
artifacts = {}
# Hashes for writing out the json API files
versions_api = {}
artifact_api = {}

# Find all metadata.json files and build versions and artifact hashes
CHANNELS.each do |channel|
  manifests = Dir.glob("#{BASE_PATH}/#{channel}/#{PRODUCT}/*/*/*metadata.json")
  artifacts[channel] = {}
  i = 0
  manifests.each do |manifest|
    m_file = File.read(manifest)
    m = JSON.parse(m_file)
    if versions[channel].nil?
      versions[channel] = [m['version']]
    else
      versions[channel][i] = m['version']
    end
    if artifacts[channel][m['version']].nil?
      artifacts[channel][m['version']] = { m['basename'] => m }
    else
      artifacts[channel][m['version']][m['basename']] = m
    end
    i += 1
  end
  versions[channel]&.sort!&.uniq!
end

# Build versions json for each channel
versions.each do |channel, v|
  versions_api[channel] = { 'results' => [{ 'properties' => [] }] }
  versions_api[channel]['results'][0]['properties'][0] = { 'key' => 'omnibus.version', 'value' => v }
end

# Build artifact json for each channel and version
artifacts.each do |channel, version|
  artifact_api[channel] = {}
  version.each do |ver, file|
    i = 0
    artifacts_channel = { 'results' => [{}] }
    file.each do |name, value|
      artifacts_channel['results'][i] =
        {
          'name' => name,
          'properties' => [
            {
              'key' => 'omnibus.project',
              'value' => value['name']
            },
            {
              'key' => 'omnibus.version',
              'value' => value['version']
            },
            {
              'key' => 'omnibus.architecture',
              'value' => value['arch']
            },
            {
              'key' => 'omnibus.license',
              'value' => value['license']
            },
            {
              'key' => 'omnibus.md5',
              'value' => value['md5']
            },
            {
              'key' => 'omnibus.platform',
              'value' => value['platform']
            },
            {
              'key' => 'omnibus.platform_version',
              'value' => value['platform_version']
            },
            {
              'key' => 'omnibus.sha1',
              'value' => value['sha1']
            },
            {
              'key' => 'omnibus.sha256',
              'value' => value['sha256']
            }
          ]
        }
      i += 1
    end
    artifact_api[channel][ver] = artifacts_channel
  end
end

# Create versions json files for all versions for each channel
versions_api.each do |channel, _versions|
  FileUtils.mkdir_p(File.join(API_PATH, 'v1', PRODUCT, channel))
  File.open(File.join(API_PATH, 'v1', PRODUCT, channel, 'versions'), 'w') do |f|
    f.write(JSON.pretty_generate(versions_api[channel]))
  end
end

# Create artifacts json files for all channels and versions
artifact_api.each do |channel, version|
  version.each do |ver, _value|
    FileUtils.mkdir_p(File.join(API_PATH, 'v1', PRODUCT, channel, ver))
    File.open(File.join(API_PATH, 'v1', PRODUCT, channel, ver, 'artifacts'), 'w') do |f|
      f.write(JSON.pretty_generate(artifact_api[channel][ver]))
    end
  end
end
