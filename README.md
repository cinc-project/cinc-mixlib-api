# cinc-mixlib-api

This provides a simple script to generate an api which is compatible with
mixlib-install and somewhat replicates a minimal Artifactory API.

## Usage

Set the following environment variables:

- ``CINC_FILES`` - Path to directory where all of the metadata.json files
	reside. Defaults to ``downloads/files``.
- ``CINC_API`` - Path to write api json files. Defaults to ``api``.
- ``CINC_PRODUCT`` - Name of the "product" to build the api files for. Defaults
	to ``cinc``.

``` console
$ export CINC_FILES=/data/mirror/files
$ export CINC_API=/data/mirror/api
$ export CINC_PRODUCT=cinc-auditor
$ ruby cinc-mixlib-api.rb
```

## File directory structure

The directory which contains the packages must following the following format
which is required to support mixlib-install:

``` console
files/$channel/$product/$platform/$platform_version/
```

Here's an actual example of what it expects:

```
files/
├── stable
│   ├── cinc
│   │   ├── centos
│   │   │   └── 7
│   │   │       ├── cinc-15.3.14-1.el7.x86_64.rpm
│   │   │       └── cinc-15.3.14-1.el7.x86_64.rpm.metadata.json
│   │   └─── debian
│   │       └─── 10
│   │           ├── cinc_15.3.14-1_amd64.deb
│   │           └── cinc_15.3.14-1_amd64.deb.metadata.json
│   └── cinc-auditor
│       ├── centos
│       │   └── 7
│       │       ├── cinc-auditor-4.17.7-1.el7.x86_64.rpm
│       │       └── cinc-auditor-4.17.7-1.el7.x86_64.rpm.metadata.json
│       └─── debian
│           └─── 10
│               ├── cinc-auditor_4.17.7-1_amd64.deb
│               └── cinc-auditor_4.17.7-1_amd64.deb.metadata.json
└── unstable
    └─── cinc
         └─── centos
            └── 7
                ├── cinc-15.4.2-1.el7.x86_64.rpm
                └── cinc-15.4.2-1.el7.x86_64.rpm.metadata.json

```

## TODO

This is currently in heavy development and will have many changes

- [ ] Split into a proper script with a library
- [ ] Create gemspec
- [ ] Add tests

# Authors

Originally written by Lance Albertson <lance@osuosl.org>

## License and Copyright

Copyright 2019, Cinc Project

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
