# frozen_string_literal: true

require 'json'

base_path = '/home/lance/git/cinc/downloads/files'
CHANNELS = %w[stable current unstable].freeze

versions = []
artifacts = {}

CHANNELS.each do |channel|
  manifests = Dir.glob("#{base_path}/#{channel}/cinc/*/*/*metadata.json")
  manifests.each do |manifest|
    m_file = File.read(manifest)
    m = JSON.parse(m_file)
    versions.push(m['version'])
    if artifacts[m['version']].nil?
      artifacts[m['version']] = { m['basename'] => m }
    else
      artifacts[m['version']][m['basename']] = m
    end
  end
end

versions.sort!.uniq!
versions_api = { 'results' => [{ 'properties' => [] }] }

i = 0
versions.each do |v|
  versions_api['results'][0]['properties'][i] = { 'key' => 'omnibus.version', 'value' => v }
  i += 1
end

artifact_versions = {}

artifacts.each do |version, file|
  i = 0
  artifacts_api = { 'results' => [{}] }
  file.each do |name, value|
    artifacts_api['results'][i] =
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
  artifact_versions[version] = artifacts_api
end

puts JSON.pretty_generate(versions_api)
# puts JSON.pretty_generate(artifacts)
# puts JSON.pretty_generate(artifacts_api)
# puts JSON.pretty_generate(artifact_versions)
