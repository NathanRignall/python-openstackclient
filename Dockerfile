# Copyright (c) 2020 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM docker.io/opendevorg/python-builder:3.11-bookworm as builder

COPY . /tmp/src
RUN assemble
    
FROM docker.io/opendevorg/python-base:3.11-bookworm

# Install git (needed for pip to install from git+https URLs)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /output/ /output
RUN /output/install-from-bindep

# Ensure pip, setuptools, and wheel are up to date
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install the heat client from GitHub
RUN pip install --no-cache-dir git+https://github.com/openstack/python-heatclient.git@stable/2025.1

# Trigger entrypoint loading to trigger stevedore entrypoint caching
RUN openstack --help >/dev/null 2>&1

CMD ["/usr/local/bin/openstack"]
