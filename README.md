# Itemengine SDK - Ruby
---

The Itemengine SDK for Ruby is a library that simplifies interaction with Itemengine APIs. It provides several convenience features that facilitate the creation of signed security requests for API initialization and interaction with the Data API.

## Table of Contents

- [Itemengine SDK - Ruby](#itemengine-sdk---ruby)
  - [Table of Contents](#table-of-contents)
  - [Overview: what does it do?](#overview-what-does-it-do)
  - [Requirements](#requirements)
    - [Supported Ruby Versions](#supported-ruby-versions)
  - [Installation](#installation)
    - [**Installation via RubyGems**](#installation-via-rubygems)
    - [**Alternative method 1: download the zip file**](#alternative-method-1-download-the-zip-file)
    - [**Alternative 2: development install from a git clone**](#alternative-2-development-install-from-a-git-clone)
  - [Usage tracking](#usage-tracking)

## Overview: what does it do?
The Itemengine Ruby SDK simplifies the interaction with Itemengine APIs by providing a number of convenience features for developers, such as creating signed security requests for API initialization and interacting with the Data API.

For example, the SDK helps create a signed request for Itemengine, which is then sent to an API in the Itemengine cloud, retrieving the requested data.

[(Back to top)](#table-of-contents)

## Requirements

1. Runtime libraries for Ruby installed. ([instructions](https://www.ruby-lang.org/en/downloads/branches/))

2. The [RubyGems](https://rubygems.org/) package manager installed.

### Supported Ruby Versions
The Ruby SDK supports the "normal maintenance" and "security maintenance" versions listed on the [Ruby home page](https://www.ruby-lang.org/en/downloads/branches/). In case of any issues with a specific version, the support team can be contacted.

[(Back to top)](#table-of-contents)

## Installation
There are three ways to install the Itemengine SDK for Ruby:

### **Installation via RubyGems**
Using RubyGems is the recommended way to install the Itemengine SDK for Ruby in production. The following command can be run from the project folder:

``` bash
gem install itemengine_sdk
```

### **Alternative method 1: download the zip file**
The latest version of the SDK can be downloaded as a self-contained ZIP file from the GitHub page, containing all the necessary dependencies. After installation, the following command needs to be run in the SDK root folder:

``` bash
bundle install
```

### **Alternative 2: development install from a git clone**
The SDK can be installed from the terminal by running the following command:

``` bash
git clone <repo-link>   
```

After installation, the following command needs to be run in the SDK root folder:

``` bash
bundle install
```

Note that these manual installation methods are for development and testing only. For production use, the SDK should be installed using the RubyGems package manager for Ruby, as described above.

[(Back to top)](#table-of-contents)

## Usage tracking
The SDK includes code to track certain information by adding it to the request being signed,:

- SDK version
- SDK language
- SDK language version
- Host platform (OS)
- Platform version

We use this data to enable better support and feature planning.

[(Back to top)](#table-of-contents)
